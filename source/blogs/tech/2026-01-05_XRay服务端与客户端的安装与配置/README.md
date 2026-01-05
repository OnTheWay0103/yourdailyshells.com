# XRay服务端与客户端的安装与配置

## GitHub网址

- 官网：https://www.softether.org/
- 源码：https://github.com/SoftEtherVPN/SoftEtherVPN
- 对应的客户端：windows版本比较完善

softether没有找到合适的客户端（匹配android手机和MAC M1电脑），所以改用docker的xray方案：V2Ray/Xray 一键脚本

## 安装服务端

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
docker run -d --name xray --network host -v /etc/xray:/etc/xray -v /etc/letsencrypt:/etc/letsencrypt teddysun/xray
```

### 手动方案

```bash
# bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
# github 地址： https://github.com/XTLS/Xray-core?tab=readme-ov-file
```

## 服务端的配置

### 方案A：VLESS + XTLS（推荐，性能最好）
```bash
# 安装 certbot（如果还没有）
sudo apt update
sudo apt install certbot -y

# 申请证书（需要有域名并解析到服务器IP）
sudo certbot certonly --standalone -d your-domain.com --non-interactive --agree-tos -m your-email@example.com

# 创建证书软链接到 Xray 目录，docker中可以不能正确识别这个路径，更换路径或者拷贝文件
sudo ln -sf /etc/letsencrypt/live/your-domain.com/fullchain.pem /etc/xray/cert.pem
sudo ln -sf /etc/letsencrypt/live/your-domain.com/privkey.pem /etc/xray/key.pem

# 也可以复制证书文件到 /etc/xray
# sudo cp -L /etc/letsencrypt/live/vpn.chatgptmessagetree.com/fullchain.pem /etc/xray/cert.pem
# sudo cp -L /etc/letsencrypt/live/vpn.chatgptmessagetree.com/privkey.pem /etc/xray/key.pem

# 设置正确权限
# sudo chmod 644 /etc/xray/cert.pem
# sudo chmod 600 /etc/xray/key.pem

# 测试TLS连接
# openssl s_client -connect localhost:443 -servername vpn.chatgptmessagetree.com

# 设置证书自动续期（重要！）使用这个定时更新，需要把使用letsencrypt的证书路径或者用脚本再同步证书
sudo crontab -e
# 添加一行：0 12 * * * /usr/bin/certbot renew --quiet && docker restart xray

docker restart xray
docker logs xray  # 检查是否有错误
```

### 方案B：VMess + WebSocket（兼容性好）
```bash
sudo mkdir -p /etc/xray

UUID=$(cat /proc/sys/kernel/random/uuid)
echo "你的UUID: $UUID"

sudo tee /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10086,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ray"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

sudo chmod 644 /etc/xray/config.json
```

## 测试服务端是否正常
```bash
# 检查端口是否监听
netstat -tlnp | grep 443

# 检查 Xray 日志
journalctl -u xray -f

# 测试 TLS 证书
openssl s_client -connect your-domain.com:443 -servername your-domain.com
# openssl s_client -connect vp2.chatgptmessagetree.com:443 -servername vp2.chatgptmessagetree.com
```

## 客户端安装

可以在官网 https://github.com/XTLS/Xray-core?tab=readme-ov-file 查找支持的客户端

### MAC M1客户端

```bash
brew install --cask v2rayu
```

或者手动安装后执行：

```bash
sudo xattr -cr /Applications/V2rayU.app  # 清除所有扩展属性
# 或者
sudo xattr -dr com.apple.quarantine /Applications/V2rayU.app
```

## 客户端配置

### 方案A（VLESS+XTLS）

- 地址：你的域名或服务器IP
- 端口：443
- UUID：上面生成的UUID
- 加密：none
- 传输：tcp
- TLS：开启
- 流控：xtls-rprx-vision

### 方案B（VMess+WS）

- 地址：服务器IP
- 端口：10086
- UUID：上面生成的UUID
- 加密：auto
- 传输：ws
- 路径：/ray

## 测试连通性
```bash
# 在服务器上测试端口（方案B）
telnet localhost 10086

# 测试TLS端口（方案A）
openssl s_client -connect localhost:443
```

### 测试步骤

1. **先测试国内网站**：访问 baidu.com，应该能正常访问
2. **再测试国外网站**：访问 google.com，应该通过代理访问
3. **检查IP地址**：访问 ip.sb 或 ipinfo.io，应该显示服务器IP

```bash
curl -s https://ipinfo.io/ip
curl -x socks5://127.0.0.1:1080 https://ipinfo.io
curl -x socks5://127.0.0.1:1080 -v https://www.google.com
```

## 速度测试

```bash
# 在服务器上测试到客户端的网络
# 使用 speedtest-cli
sudo apt install speedtest-cli
speedtest-cli
```

## 代理模式说明

- **PAC 模式（推荐）**：只有被规则列表匹配的网站（通常是国外网站）才会走代理，国内网站直连。速度更快，流量更省。
- **全局模式**：所有网络请求都通过代理服务器。可以用来初步测试连通性。