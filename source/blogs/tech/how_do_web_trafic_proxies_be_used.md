# 网络代理的使用方案

要实现指定网站走代理、默认网站直连的网络代理设置，关键在于配置智能流量分流规则（白名单模式）。以下是具体操作方法和注意事项，涵盖不同场景的配置方案：

## 一、核心原理：白名单模式

通过设置代理规则，仅允许特定域名或 IP 通过代理访问，其他流量直接连接。这种方式比全局代理更高效，尤其适合需要区分国内外流量的场景（如访问国际电商、海外学术资源）。

## 二、常用配置方法

根据使用场景和技术能力选择合适方案：

### 1. 浏览器插件配置（适合新手）

适用工具：SwitchyOmega、Proxy SwitchySharp 等浏览器扩展。

操作步骤：

- 安装插件后，新建情景模式（如命名"智能代理"）
- 在「代理规则」或「条件设置」中：
  - 添加需代理的域名（如 .amazon.com, .google.com）
  - 选择「规则列表匹配时走代理」
  - 默认规则设为「直接连接」

优点：无需系统权限，操作简单。

### 2. 系统级代理设置（Windows/macOS/Linux）

操作路径：

- Windows：设置 > 网络 > 代理 > 手动设置代理 → 在「不使用代理的地址」栏填入国内域名（如 .baidu.com, .taobao.com）
- macOS：系统设置 > 网络 > 代理 → 勾选「忽略这些主机与域的代理设置」并添加直连域名

注意：需配合代理服务商提供的 IP 地址使用（如神龙代理支持生成白名单脚本）。

### 3. 命令行/脚本配置（适合技术人员）

Git 代理白名单示例：

```bash
# 设置代理
git config --global http.proxy http://proxy.example.com:8080
# 添加直连域名（如国内仓库）
git config --global --add http.proxyExclude "*.gitee.com"
```

此配置让 gitee.com 直连，其他走代理。

### 4. 编程实现智能分流（Python 示例）

```python
import requests

# 白名单列表
allow_list = ["amazon.com", "ebay.com"]

def proxy_request(url):
    if any(domain in url for domain in allow_list):
        proxies = {"http": "http://proxy_ip:port", "https": "http://proxy_ip:port"}
        return requests.get(url, proxies=proxies)
    else:
        return requests.get(url)  # 直连
```

此代码仅对白名单内域名启用代理。

## 三、关键注意事项

### 域名格式规范：

- 使用通配符 \* 匹配子域名（如 .google.com 包含 drive.google.com）
- 避免遗漏顶级域名（如 amazon.com 和 amazon.co.jp 需分开添加）

### 代理服务商选择：

- 确保服务商支持白名单功能（如神龙代理、天启代理提供 IP 段 CIDR 格式）
- 动态 IP 服务需配合 API 实时更新白名单（天启代理支持动态密钥签名）

### 性能与安全优化：

- 流量监控：设置请求阈值（如单 IP 每小时 ≤500 次），防止滥用
- 协议适配：视频传输用 SOCKS5，网页交互用 HTTP/HTTPS
- 地域轮换：同城代理 IP 使用不超过 30 分钟，避免封禁

## 四、典型场景配置示例

| 场景            | 推荐方案                | 白名单示例                    |
| --------------- | ----------------------- | ----------------------------- |
| 跨境电商运营    | 浏览器插件 + 地域轮换   | .amazon.com, .ebay.com        |
| 学术资源访问    | 系统代理 + 直连国内域名 | .sciencedirect.com, .ieee.org |
| 企业数据采集    | 编程实现 + IP 动态更新  | 通过 API 实时获取目标站点域名 |
| 开发环境（Git） | Git 命令排除国内仓库    | .gitee.com, .aliyun.com       |

## 五、常见问题解决

### Q：配置后部分网站无法访问？

- 检查域名是否拼写错误
- 用 ping 或 nslookup 验证域名解析

### Q：动态 IP 如何避免频繁更新白名单？

- 使用服务商提供的动态密钥（如天启代理签名验证）

### Q：代理速度慢？

- 切换协议（HTTP→SOCKS5）或启用备用节点池

通过合理配置白名单，既可保障关键业务的高速代理访问，又能避免无关流量消耗资源。企业级应用建议结合 IP 指纹校验+API 令牌双层防护，进一步提升安全性。
