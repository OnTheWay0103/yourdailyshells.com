# iptables 的用法

--- 

iptables是 Linux 系统上历史悠久且功能强大的**用户空间命令行工具**，用于配置、管理和维护 Linux 内核中的 **Netfilter** 防火墙模块。简单来说，`iptables` 让你可以定义规则，决定如何处理进入、离开或经过你 Linux 机器的网络数据包（包过滤、网络地址转换等）。

## 核心概念

在深入命令之前，理解几个核心概念至关重要：

1.  **表：**
    *   规则被组织在不同的“表”中，每个表用于特定目的。
    *   主要的表有：
        *   **`filter` 表：** **最常用**的表。负责**包过滤**（决定是否允许数据包通过）。包含 `INPUT`, `OUTPUT`, `FORWARD` 链。
        *   **`nat` 表：** 用于**网络地址转换**（NAT）。当数据包创建新连接时使用。包含 `PREROUTING`, `OUTPUT`, `POSTROUTING` 链。
        *   **`mangle` 表：** 用于**修改**数据包内容（如 TOS, TTL, MARK 等特殊标记）。包含所有 5 个链。
        *   **`raw` 表：** 用于配置数据包是否被连接跟踪机制处理（主要用于豁免某些包）。包含 `PREROUTING`, `OUTPUT` 链。
        *   **`security` 表：** (较少用) 用于强制访问控制网络规则（如 SELinux）。包含 `INPUT`, `OUTPUT`, `FORWARD` 链。

2.  **链：**
    *   每个表包含预定义的“链”。链是规则的有序列表。
    *   数据包在网络栈的不同处理点被送到特定的链中进行规则匹配。
    *   主要的链有：
        *   **`PREROUTING`:** 数据包**刚进入网络接口之后、路由决策之前**。常用于 `nat` (目标地址转换 DNAT) 和 `mangle`。
        *   **`INPUT`:** 数据包目标是**本机**（例如访问本机的 SSH 服务），在路由决策之后。主要用于 `filter` 表。
        *   **`FORWARD`:** 数据包目标是**另一台机器**（本机作为路由器），在路由决策之后。主要用于 `filter` 表。
        *   **`OUTPUT`:** 数据包由**本机进程产生**并准备发送出去。用于 `filter`, `nat`, `mangle` 等表。
        *   **`POSTROUTING`:** 数据包**离开网络接口之前**。常用于 `nat` (源地址转换 SNAT/MASQUERADE) 和 `mangle`。

3.  **规则：**
    *   链中的每一条规则都包含：
        *   **匹配条件：** 指定该规则应用于哪些数据包（如源 IP、目标 IP、协议、端口、接口等）。
        *   **目标：** 如果数据包匹配了规则的条件，应该对它做什么操作（动作）。
    *   数据包会按顺序遍历链中的规则。一旦匹配到一条规则，就会执行该规则指定的目标动作，**停止**遍历该链的后续规则（除非目标动作是 `LOG` 等特殊动作）。
    *   如果数据包遍历完链中的所有规则都没有匹配，则执行该链的**默认策略**。

4.  **目标：**
    *   规则匹配后执行的动作。常见目标有：
        *   **`ACCEPT`:** 允许数据包通过。
        *   **`DROP`:** 静默丢弃数据包（发送方不会收到任何错误提示）。
        *   **`REJECT`:** 丢弃数据包，并向发送方发送一个错误响应（如 TCP RST 或 ICMP port unreachable）。
        *   **`LOG`:** 将数据包信息记录到系统日志（如 `/var/log/syslog` 或 `/var/log/messages`）。这是一个**非终止**目标，数据包会继续被后续规则检查。
        *   **`DNAT`:** (在 `nat` 表的 `PREROUTING` 链) 修改数据包的目标地址（端口转发）。
        *   **`SNAT`:** (在 `nat` 表的 `POSTROUTING` 链) 修改数据包的源地址。
        *   **`MASQUERADE`:** (在 `nat` 表的 `POSTROUTING` 链) 一种特殊的 `SNAT`，用于动态获取 IP 地址的接口（如拨号上网、DHCP）。它会自动使用接口当前的 IP 地址。
        *   **`RETURN`:** 停止在当前链中继续匹配，返回到调用此链的上一条规则处继续执行。如果是在内置链中遇到 `RETURN`，则执行该链的默认策略。

5.  **策略：**
    *   每个内置链 (`INPUT`, `OUTPUT`, `FORWARD`, `PREROUTING`, `POSTROUTING`) 都有一个默认策略。
    *   默认策略决定了当数据包遍历完链中所有规则都**没有匹配**任何规则时，应该如何处理该数据包。
    *   常见的默认策略是 `ACCEPT` 或 `DROP`。强烈建议将默认策略设置为 `DROP` 或 `REJECT` 以提高安全性（白名单模式），但设置前务必确保不会把自己锁在外面（比如先放行 SSH）。

## 基本命令语法

`iptables` 命令的基本结构如下：

```bash
iptables [-t table] command [chain] [match-criteria] -j target
```

*   **`-t table`:** 指定操作哪个表。如果省略，默认为 `filter` 表。
*   **`command`:** 对链或规则执行的操作（见下文）。
*   **`chain`:** 指定操作哪个链。
*   **`match-criteria`:** 定义规则匹配数据包的条件（见下文）。
*   **`-j target`:** 指定匹配规则后执行的目标动作。

## 常用命令

*   **查看规则：**
    *   `iptables -L`: 列出 `filter` 表所有链的所有规则（默认视图）。
    *   `iptables -L -v`: 列出规则并显示更详细信息（数据包计数、字节计数）。
    *   `iptables -L -n`: 以数字形式显示 IP 和端口（避免 DNS 反向解析，更快）。
    *   `iptables -L -t nat`: 列出 `nat` 表的所有规则。
    *   `iptables -S [chain]`: 以 `iptables-save` 格式输出规则（显示完整的命令形式，便于复制或保存）。

*   **管理链：**
    *   `iptables -N my_chain`: 在 `filter` 表（或 `-t` 指定的表）中创建一条新的**用户自定义链** `my_chain`。
    *   `iptables -X my_chain`: 删除名为 `my_chain` 的**空**用户自定义链。
    *   `iptables -F [chain]`: 清空指定链中的所有规则。如果不指定链名，则清空指定表（默认为 `filter`）中所有链的规则。**(谨慎使用！)**
    *   `iptables -P chain target`: 设置链的**默认策略**。例如 `iptables -P INPUT DROP`。**(设置前务必确认！)**

*   **管理规则：**
    *   `iptables -A chain [match-criteria] -j target`: **追加**一条规则到指定链的末尾。
    *   `iptables -I chain [rulenum] [match-criteria] -j target`: **插入**一条规则到指定链的指定位置（`rulenum`，默认为 1，即链首）。
    *   `iptables -R chain rulenum [match-criteria] -j target`: **替换**指定链中指定位置的规则。
    *   `iptables -D chain rulenum`: 按**序号**删除指定链中的规则。
    *   `iptables -D chain [match-criteria] -j target`: 按**匹配条件**删除指定链中的规则（需要精确匹配规则内容）。
    *   `iptables -Z [chain]`: 将指定链（或所有链）中的数据包和字节计数器**清零**。

## 常用匹配条件

*   **接口：**
    *   `-i input_interface`: 指定数据包**进入**的网络接口（如 `eth0`, `wlan0`）。用于 `PREROUTING`, `INPUT`, `FORWARD` 链。
    *   `-o output_interface`: 指定数据包**离开**的网络接口。用于 `FORWARD`, `OUTPUT`, `POSTROUTING` 链。
*   **协议：**
    *   `-p protocol`: 指定协议类型，如 `tcp`, `udp`, `icmp`, `icmpv6`, `all`。
*   **IP 地址：**
    *   `-s source_address[/mask]`: 指定源 IP 地址或网段（如 `192.168.1.100`, `10.0.0.0/24`）。
    *   `-d destination_address[/mask]`: 指定目标 IP 地址或网段。
*   **端口 (需要 `-p tcp` 或 `-p udp`):**
    *   `--sport source_port`: 指定源端口号或范围（如 `22`, `80:443`）。
    *   `--dport destination_port`: 指定目标端口号或范围。
*   **连接状态 (需要 `conntrack` 模块)：**
    *   `-m conntrack --ctstate state`: 匹配连接状态。常用状态：
        *   `NEW`: 新建立的连接。
        *   `ESTABLISHED`: 属于已建立连接的数据包（有响应）。
        *   `RELATED`: 与某个已建立连接相关联的新连接（如 FTP 的数据连接）。
        *   `INVALID`: 无效或无法识别的数据包。
    *   `-m state --state state`: (旧语法，等价于上面，但 `state` 模块已过时，推荐用 `conntrack`)。

## 重要注意事项

1.  **规则顺序至关重要：** 规则按其在链中的顺序从上到下执行。第一条匹配的规则决定了数据包的命运。确保更具体的规则放在更通用的规则前面。例如，放行 SSH 的规则应该在默认 DROP 规则之前。
2.  **默认策略：** 设置默认策略为 `DROP` 或 `REJECT` 是良好实践（白名单安全模型）。但**务必**在设置默认 `DROP` 策略之前，先添加允许你远程管理（如 SSH）和访问本地回环接口 (`lo`) 的规则！否则你可能会立即失去对服务器的访问权限。
3.  **保存规则：** `iptables` 命令设置的规则**默认在系统重启后会丢失**。你需要使用发行版特定的方法保存规则：
    *   Debian/Ubuntu: `sudo netfilter-persistent save` (或 `sudo iptables-save > /etc/iptables/rules.v4` 然后配置 `netfilter-persistent` 服务自动加载)。
    *   RHEL/CentOS 7+: `sudo iptables-save > /etc/sysconfig/iptables` (或 `/etc/sysconfig/iptables`)，然后启用 `iptables` 服务 (`systemctl enable iptables`)。CentOS 7+ 默认使用 `firewalld`。
    *   RHEL/CentOS 8+/Fedora: 默认使用 `firewalld` 或 `nftables`。如果需要坚持用 `iptables`，需禁用 `firewalld` (`systemctl disable --now firewalld`)，安装 `iptables-services` (`yum install iptables-services`)，然后使用 `service iptables save` 或 `iptables-save > /etc/sysconfig/iptables`。
4.  **`nftables` 是未来：** `iptables` 正在逐渐被 `nftables` 取代。`nftables` 提供了更统一的语法、更好的性能和更丰富的特性。许多新发行版默认或推荐使用 `nftables`。学习 `nftables` 也是一个好主意。
5.  **谨慎操作：** 尤其是在远程管理服务器时，错误的 `iptables` 规则可能导致你无法访问服务器。建议在操作前备份现有规则 (`iptables-save > iptables-backup.txt`)，并在可能的情况下在测试环境练习，或者设置一个定时任务在几分钟后恢复规则（如果操作失误锁住了自己）。

## 常见示例

1.  **允许已建立的连接和回环接口：**
    ```bash
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    ```

2.  **允许 SSH 访问 (端口 22)：**
    ```bash
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    ```

3.  **允许 HTTP (80) 和 HTTPS (443) 访问：**
    ```bash
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    ```

4.  **允许 Ping (ICMP Echo Request)：**
    ```bash
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
    ```

5.  **设置默认策略为 DROP：**
    ```bash
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT  # 通常允许所有出站
    ```
    *注意：务必在执行此命令前添加好必要的放行规则（如上面 1-4 的规则）！*

6.  **端口转发 (DNAT)：** 将到达本机公网 IP 端口 8080 的 TCP 流量转发到内网服务器 192.168.1.100 的 80 端口。
    ```bash
    iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.100:80
    iptables -t filter -A FORWARD -p tcp -d 192.168.1.100 --dport 80 -j ACCEPT  # 通常还需要在 FORWARD 链放行
    ```

7.  **共享上网 (SNAT/MASQUERADE)：** 假设本机 eth0 是内网接口 (192.168.1.1)， eth1 是连接公网的接口（IP 可能动态获取）。
    ```bash
    iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    # 还需要确保内核启用了 IP 转发 (sysctl net.ipv4.ip_forward=1)
    ```

8.  **记录被丢弃的数据包：**
    ```bash
    iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
    iptables -A INPUT -j DROP  # 确保这条规则在 LOG 规则之后
    ```

## 总结

`iptables` 是一个强大但复杂的工具。理解表、链、规则、匹配条件和目标的概念是有效使用它的基础。始终记住规则顺序的重要性、谨慎设置默认策略、并记得保存规则。对于新系统，建议了解和学习 `nftables`。通过实践和参考文档，你可以利用 `iptables` 构建出满足需求的防火墙规则集。