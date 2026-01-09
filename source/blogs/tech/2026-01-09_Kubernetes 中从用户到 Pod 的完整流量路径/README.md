# Kubernetes 中从用户到 Pod 的完整流量路径


## 核心组件的作用

首先理解各组件的作用：
- **Service**：逻辑抽象，定义一组 Pod 的访问策略
- **kube-proxy**：在每个节点上运行，实现 Service 的负载均衡规则
- **Ingress**：外部 HTTP(S) 流量入口，提供基于域名/路径的路由
- **NodePort**：Service 的一种类型，在节点上打开固定端口
- **Pod**：实际运行应用的容器组

## 1. 通过 ClusterIP 访问（集群内部）

```
用户应用 -> ClusterIP -> kube-proxy (iptables/ipvs) -> Pod
```

**详细步骤：**
1. 应用在 Pod 中调用 `my-service:8080`
2. DNS 解析返回 Service 的 ClusterIP（虚拟 IP）
3. 节点上的 kube-proxy 通过以下方式之一转发：
   - **iptables 模式**（默认）：设置 DNAT 规则，将目标 ClusterIP:Port 改为随机选择的 Pod IP:Port
   - **ipvs 模式**：使用内核 IPVS 做负载均衡，性能更好
4. 流量到达目标 Pod

## 2. 通过 NodePort 访问（外部访问）

```
用户 -> NodeIP:NodePort -> kube-proxy -> Pod
```

**详细步骤：**
```
用户浏览器访问 10.0.0.1:30080
    ↓
Node1 (10.0.0.1) 的 30080 端口
    ↓
Node1 的 kube-proxy 拦截
    ↓
kube-proxy 检查 iptables/IPVS 规则
    ↓
目标替换为 Pod IP:Port (如 10.244.1.2:8080)
    ↓
如果 Pod 在 Node2，跨节点转发
    ↓
到达 Pod 容器
```

## 3. 通过 Ingress 访问（生产推荐）

```
用户 -> LoadBalancer/NodePort -> Ingress Controller -> Service -> Pod
```

**详细步骤（以 Nginx Ingress 为例）：**

```
用户访问 https://app.example.com
    ↓
DNS 解析到外部负载均衡器 IP
    ↓
云厂商 LoadBalancer (如 ELB/ALB) 或 NodePort
    ↓
Ingress Controller Pod (运行在集群内)
    ↓
Ingress Controller 检查 Ingress 规则
    ↓
转发到对应的 Service (backend-service:80)
    ↓
kube-proxy 负载均衡到 Pod
    ↓
到达目标 Pod
```

## 4. 通过 LoadBalancer 访问（云厂商）

```
用户 -> 云负载均衡器 -> NodePort/Ingress -> Pod
```

## 详细的流量路径示例

### 场景：通过 Ingress 访问应用

```yaml
# 1. 用户定义的资源
Deployment: 运行 3 个 Pod
Service: ClusterIP 类型，选择器匹配 Pod
Ingress: 定义路由规则
Ingress Controller: 已部署的 Nginx Controller
```

### 流量路径详解：

```
外部用户
    ↓
1. DNS 解析 app.example.com → 34.107.100.200 (LoadBalancer IP)
    ↓
2. 云负载均衡器 (AWS ALB / GCP LB)
    ↓
3. 目标组 → NodePort 31456 (所有节点)
    ↓
4. Node1:31456 → kube-proxy 拦截
    ↓
5. kube-proxy 转发到 Ingress Controller Pod (10.244.1.5:80)
    ↓
6. Nginx Ingress Controller
   - 检查 Host: app.example.com
   - 查找对应的 Ingress 规则
   - 确定后端 Service: app-service:80
    ↓
7. 查询 app-service 的 Endpoints (实际是 Pod IPs)
    ↓
8. 负载均衡到某个 Pod IP: 10.244.2.3:8080
    ↓
9. 如果 Pod 在其他节点，通过 CNI 网络插件跨节点通信
    ↓
10. 到达目标 Pod 的容器
```

## 网络模型的关键点

### 1. kube-proxy 的工作
```bash
# 查看 iptables 规则示例
iptables -t nat -L KUBE-SERVICES
# 会看到类似规则：
# KUBE-SVC-XXXX -> KUBE-SEP-YYYY -> PodIP:Port
```

### 2. Endpoints 和 EndpointSlice
```yaml
# Service 不直接连接 Pod，而是通过：
# - Endpoints: 存储 Pod IP:Port 列表
# - kube-proxy 监听 Endpoints 变化，更新规则
```

### 3. CNI 网络插件
- Flannel、Calico、Cilium 等
- 负责 Pod 跨节点通信
- 实现集群网络策略

## 实际数据包的变化

```
原始请求: 用户 -> NodeIP:NodePort
    ↓
节点上 DNAT: NodeIP:NodePort → PodIP:ContainerPort
    ↓
如果跨节点: 封装/路由到目标节点
    ↓
目标节点: 解封装 → Pod
```

## 调试命令

```bash
# 查看 Service
kubectl get svc
kubectl describe svc/my-service

# 查看 Endpoints
kubectl get endpoints my-service

# 查看 iptables 规则
iptables -t nat -L | grep -A 10 "KUBE-SVC"

# 查看 Pod IP
kubectl get pods -o wide

# 跟踪 Ingress
kubectl get ingress
kubectl describe ingress/my-ingress
```

## 总结

从用户到 Pod 的流量路径核心是：
1. **外部入口**：LoadBalancer/NodePort/Ingress
2. **服务发现**：Service 提供稳定的访问端点
3. **负载均衡**：kube-proxy 实现最后一跳转发
4. **网络互通**：CNI 插件确保 Pod 间网络可达

**简单记忆**：外部请求通过 Ingress/NodePort 进入 → 到达 kube-proxy → 根据 Service 规则转发 → 到达实际 Pod。

这个架构的优点是：Pod 可以随时创建销毁，IP 会变，但 Service 提供了稳定的访问端点，用户不需要知道后端 Pod 的具体位置。