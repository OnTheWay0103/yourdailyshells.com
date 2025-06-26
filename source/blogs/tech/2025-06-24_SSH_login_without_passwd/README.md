# SSH 免密码登录设置

## 目录
- [基本原理](#基本原理)
- [详细步骤](#详细步骤)
  - [第一步：生成密钥对](#第一步生成密钥对)
  - [第二步：上传公钥到服务器](#第二步上传公钥到服务器)
  - [第三步：服务器端配置](#第三步服务器端配置)
  - [第四步：本地SSH客户端配置](#第四步本地ssh客户端配置)
  - [第五步：测试连接](#第五步测试连接)
- [故障排除](#故障排除)
- [安全最佳实践](#安全最佳实践)
- [高级配置](#高级配置)

---

## 基本原理
SSH免密码登录通过**非对称加密**实现：
1. 客户端生成SSH密钥对（公钥+私钥）
2. 公钥上传到服务器的 `~/.ssh/authorized_keys` 文件
3. 连接时客户端使用私钥签名，服务器使用公钥验证
4. 认证成功即可免密码登录

---

## 详细步骤

### 第一步：生成密钥对
```bash
# 生成ed25519密钥（安全性高于RSA）
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_server -C "用于服务器登录的密钥"

# 设置密钥密码（可选，增强安全性）
Enter passphrase (empty for no passphrase): [输入密码]
Enter same passphrase again: [确认密码]
```

**文件说明**:
- 私钥: `~/.ssh/id_ed25519_server`
- 公钥: `~/.ssh/id_ed25519_server.pub`

### 第二步：上传公钥到服务器

**方法1：使用ssh-copy-id（推荐）**
```bash
ssh-copy-id -i ~/.ssh/id_ed25519_server.pub username@server_ip
# 首次需要输入服务器密码
```

**方法2：手动上传**
```bash
# 本地查看公钥内容
cat ~/.ssh/id_ed25519_server.pub

# 服务器上操作
mkdir -p ~/.ssh
echo "粘贴公钥内容" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 第三步：服务器端配置
```bash
# 编辑SSH配置文件
sudo nano /etc/ssh/sshd_config
```

**确保以下设置**:
```ini
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no   # 可选，禁用密码登录增加安全性
PermitRootLogin no          # 推荐禁止root远程登录
```

**重启SSH服务**:
```bash
sudo systemctl restart sshd
sudo systemctl status sshd  # 验证状态
```

### 第四步：本地SSH客户端配置

**创建配置文件**:
```bash
nano ~/.ssh/config
```

**添加服务器配置**:
```ini
# Tencent云服务器配置
Host myserver
    HostName 43.159.38.35     # 服务器IP
    User ubuntu               # 登录用户名
    Port 22                   # SSH端口
    IdentityFile ~/.ssh/id_ed25519_server
    IdentitiesOnly yes        # 强制使用指定密钥
    ServerAliveInterval 60    # 每60秒发送保活包
    TCPKeepAlive yes
```

**设置正确权限**:
```bash
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh
chmod 644 ~/.ssh/known_hosts
```

### 第五步：测试连接
```bash
# 使用配置文件连接
ssh myserver

# 或直接指定IP
ssh -i ~/.ssh/id_ed25519_server ubuntu@43.159.38.35
```

**成功标志**: 无需输入密码直接进入服务器终端

---

## 故障排除

### 常见问题及解决方案

| 问题现象 | 可能原因 | 解决方案 |
|---------|---------|---------|
| `Permission denied` | 密钥权限问题 | `chmod 600 ~/.ssh/id_ed25519_server` |
| `No such identity` | 密钥路径错误 | 检查`~/.ssh/config`中的路径 |
| 仍要求输入密码 | 服务器未加载公钥 | 查看`~/.ssh/authorized_keys`内容 |
| 连接超时 | 防火墙/网络问题 | `telnet server_ip 22` 测试端口 |
| `Agent admitted failure` | SSH代理未加载密钥 | `ssh-add ~/.ssh/id_ed25519_server` |

### 详细日志分析
```bash
ssh -vvv myserver 2> ssh_debug.log
```
检查日志中的关键行：
```
debug1: Offering public key: /home/user/.ssh/id_ed25519_server ED25519 SHA256:xxxx explicit
debug1: Server accepts key: pkalg ssh-ed25519 blen 279
Authenticated to server_ip ([server_ip]:22) using "publickey"
```

---

## 安全最佳实践

1. **密钥保护**
   ```bash
   # 定期更换密钥
   ssh-keygen -p -f ~/.ssh/id_ed25519_server
   
   # 备份密钥
   cp ~/.ssh/id_ed25519_server* ~/secure_backup/
   ```
2. **网络加固**
   ```ini
   # /etc/ssh/sshd_config
   LoginGraceTime 1m
   MaxAuthTries 3
   MaxStartups 3
   AllowUsers ubuntu@your_trusted_ip
   ```
3. **监控与审计**
   ```bash
   # 查看SSH登录日志
   sudo grep sshd /var/log/auth.log
   
   # 检查异常登录
   last -f /var/log/wtmp
   ```
4. **两步验证（可选）**
   ```bash
   # 安装Google Authenticator
   sudo apt install libpam-google-authenticator
   google-authenticator
   ```

---

## 高级配置

### 多服务器管理
```ini
# ~/.ssh/config
Host *.production
    IdentityFile ~/.ssh/prod_key
    User admin
    
Host *.staging
    IdentityFile ~/.ssh/staging_key
    User dev

# 示例服务器
Host webserver.production
    HostName 192.168.1.100

Host dbserver.staging
    HostName 192.168.1.200
```

### 通过代理服务器连接
```ini
Host jumpserver
    HostName proxy.example.com
    User proxyuser
    IdentityFile ~/.ssh/proxy_key

Host internal-server
    HostName 10.0.0.5
    User internaluser
    ProxyJump jumpserver
```

### SSH证书认证（企业级）
```bash
# 生成用户证书请求
ssh-keygen -s ca_key -I user_id user_key.pub

# 服务器端配置
echo "@cert-authority *.example.com $(cat ca_key.pub)" >> /etc/ssh/ssh_known_hosts
```

---

通过以上步骤，即可实现安全的SSH免密码登录，并可根据需求进行高级配置，满足各种使用场景。