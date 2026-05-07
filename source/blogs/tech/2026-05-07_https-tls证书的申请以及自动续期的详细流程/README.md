# https中tls证书的申请以及自动续期的详细流程

**“为什么 → 怎么申请 → 校验机制 → 自动续期 → 常见架构（尤其 K8S） → 故障点”** 

---

## 一、HTTPS / TLS 证书到底解决什么问题

TLS 证书的核心作用只有三点：

1. **身份认证**

   * 证明：这个域名确实属于你（不是中间人）

2. **数据加密**

   * 建立对称密钥（AES 等）
   * 防止明文被抓包

3. **数据完整性**

   * 防止内容被篡改

👉 浏览器信任你，是因为：

> 你的证书 ← 被 CA 签发 ← CA 根证书在浏览器内置的信任列表中

---

## 二、TLS 证书申请的整体流程（宏观）

不管你用的是：

* 阿里云
* 腾讯云
* Let’s Encrypt
* 私有 CA

**本质流程都是一样的：**

```
你 → 向 CA 申请证书
CA → 验证你是否拥有该域名
CA → 使用自己的私钥签发证书
你 → 在服务器上部署证书
```

差异主要在 **“域名验证方式”** 和 **“是否自动化”**。

---

## 三、证书申请的详细流程（逐步拆解）

### 1️⃣ 生成密钥对（本地或自动）

* **私钥（Private Key）**

  * 你自己保存
  * 用来解密、签名
* **公钥（Public Key）**

  * 发给 CA
  * 写进证书里

一般由工具自动生成：

* certbot
* cert-manager
* 云厂商控制台

---

### 2️⃣ 生成 CSR（Certificate Signing Request）

CSR 包含：

* 公钥
* 域名（CN / SAN）
* 组织信息（可选）

```
CSR = “我要为 example.com 申请证书，这是我的公钥”
```

---

### 3️⃣ CA 进行 **域名所有权验证（最关键）**

CA 必须确认：

> “你真的控制了 example.com”

这一步决定了你是否能**自动续期**。

---

## 四、域名验证的三种方式（重点）

### 方式一：HTTP-01（最常见）

**原理：**

* CA 要求你在：

  ```
  http://example.com/.well-known/acme-challenge/xxxxx
  ```

  返回一个指定内容

**流程：**

```
CA → 访问你的 HTTP 服务
如果返回正确内容 → 验证通过
```

**优点**

* 简单
* 不依赖 DNS API

**缺点**

* 必须暴露 80 端口
* 不适合内网 / 纯 HTTPS / 无公网 IP

---

### 方式二：DNS-01（自动续期最稳定）

**原理：**

* CA 要求你在 DNS 中创建 TXT 记录：

```
_acme-challenge.example.com = "随机字符串"
```

**流程：**

```
CA → 查询 DNS
TXT 正确 → 验证通过
```

**优点**

* 不依赖服务器
* 支持泛域名 `*.example.com`
* 非常适合 K8S

**缺点**

* 需要 DNS API 权限

👉 **alidns-webhook** 就是干这个的。

---

### 方式三：TLS-ALPN-01（较少）

* 用 443 端口
* 较复杂，少用

---

## 五、CA 签发证书后的结果

CA 返回：

* 服务器证书（server.crt）
* 中间证书（chain.crt）

你需要最终组合成：

```
fullchain.pem = server.crt + chain.crt
privkey.pem   = 私钥
```

---

## 六、HTTPS 握手过程（证书如何被用）

简化版 TLS 握手：

```
Client → ClientHello
Server → ServerHello + 证书
Client → 验证证书合法性
双方 → 协商对称密钥
后续通信 → 全部加密
```

浏览器会检查：

* 证书是否过期
* 域名是否匹配
* 是否被信任 CA 签发
* 是否被吊销

---

## 七、证书为什么需要自动续期？

* Let’s Encrypt 有效期 **90 天**
* 云厂商证书通常 **1 年**

自动续期的本质是：

> **在证书到期前，再走一遍“域名验证 + 签发流程”**

---

## 八、自动续期的核心机制（重点）

### 1️⃣ 定期检查证书有效期

例如：

* 剩余 30 天 → 触发续期
* cert-manager 默认在 2/3 生命周期时续期

---

### 2️⃣ 重新执行域名验证

**注意：**

* 续期 ≠ 简单延期
* **CA 会重新验证你是否拥有域名**

所以：

* DNS API 权限失效 → 续期失败
* Webhook 异常 → 续期失败

---

### 3️⃣ 签发新证书 & 原子替换

```
新证书 → 写入 Secret
Ingress / Nginx → 自动 reload
```

**整个过程不中断服务**

---

## 九、K8S + cert-manager 自动续期完整链路

以 **DNS-01 + 阿里云 DNS** 为例：

```
Certificate 对象
   ↓
cert-manager
   ↓
创建 Challenge
   ↓
调用 alidns-webhook
   ↓
阿里云 DNS API 写 TXT 记录
   ↓
Let’s Encrypt 验证 DNS
   ↓
签发新证书
   ↓
更新 Kubernetes Secret
   ↓
Ingress 自动使用新证书
```

---

## 十、你日志中那类问题一般卡在哪？

结合你之前的上下文（alidns-webhook + cert-manager）：

### 常见失败点

1. **DNS 权限问题**

   * RAM 权限不足
   * AccessKey 过期

2. **Webhook 未正常注册**

   * CRD 未加载
   * apiservice 未 Ready

3. **网络问题**

   * 集群无法访问 acme-v02.api.letsencrypt.org
   * DNS 被墙 / 出口受限

4. **TXT 记录延迟**

   * DNS TTL 太长
   * CA 查询到旧记录

---

## 十一、排错时你重点看什么？

### 1️⃣ cert-manager 日志

```bash
kubectl logs -n cert-manager deploy/cert-manager
```

### 2️⃣ Challenge 状态

```bash
kubectl describe challenge
```

### 3️⃣ Order 状态

```bash
kubectl describe order
```

### 4️⃣ DNS 是否真的生效

```bash
dig TXT _acme-challenge.example.com
```

---

## 十二、用一句话总结

> **TLS 证书自动续期的本质：
> “在证书快过期时，自动再次向 CA 证明你仍然控制着这个域名。”**

