# Kubernetes 入门教程：基础概念和日常管理

## 1. Kubernetes 是什么？

Kubernetes（简称 K8s）是一个开源的容器编排平台，用于自动化部署、扩展和管理容器化应用程序。

### 主要特性：
- **自动化部署**：自动部署容器化应用
- **自我修复**：自动重启失败容器、替换和重新调度容器
- **水平扩展**：根据负载自动扩展应用实例
- **服务发现和负载均衡**：自动分配网络流量
- **配置和密钥管理**：安全地管理配置信息和敏感数据
- **存储编排**：自动挂载存储系统

## 2. Kubernetes 架构

### 2.1 控制平面（Control Plane）
- **kube-apiserver**：Kubernetes API 入口
- **etcd**：分布式键值存储，保存集群所有数据
- **kube-scheduler**：调度器，决定Pod运行在哪个节点
- **kube-controller-manager**：运行各种控制器
- **cloud-controller-manager**：与云提供商API交互

### 2.2 工作节点（Worker Nodes）
- **kubelet**：节点代理，确保容器正常运行
- **kube-proxy**：网络代理，实现Service网络
- **容器运行时**：如Docker、containerd

## 3. 核心概念

### 3.1 Pod
- Kubernetes的最小部署单元
- 包含一个或多个紧密相关的容器
- 共享网络和存储空间
- 临时性资源（可以被销毁和重建）

### 3.2 Deployment
- 管理Pod副本集的控制器
- 声明式地定义Pod的期望状态
- 支持滚动更新和回滚
- 确保指定数量的Pod副本运行

### 3.3 Service
- 为Pod提供稳定的网络端点
- 实现服务发现和负载均衡
- 类型：ClusterIP、NodePort、LoadBalancer

### 3.4 Namespace
- 虚拟集群，用于资源隔离
- 默认命名空间：default、kube-system、kube-public
- 实现多租户环境

### 3.5 ConfigMap 和 Secret
- **ConfigMap**：存储非敏感配置数据
- **Secret**：存储敏感信息（密码、令牌等）

## 4. 基本 kubectl 命令

### 4.1 集群信息
```bash
# 查看集群信息
kubectl cluster-info

# 查看节点状态
kubectl get nodes

# 查看组件状态
kubectl get componentstatuses
```

### 4.2 资源管理
```bash
# 查看所有Pod
kubectl get pods --all-namespaces

# 查看Deployment
kubectl get deployments

# 查看Service
kubectl get services

# 查看Namespace
kubectl get namespaces
```

### 4.3 创建资源
```bash
# 通过YAML文件创建资源
kubectl apply -f deployment.yaml

# 运行一个临时Pod
kubectl run nginx --image=nginx --port=80
```

### 4.4 查看和调试
```bash
# 查看Pod详情
kubectl describe pod <pod-name>

# 查看Pod日志
kubectl logs <pod-name>

# 进入Pod容器
kubectl exec -it <pod-name> -- /bin/bash

# 查看资源使用情况
kubectl top pods
kubectl top nodes
```

### 4.5 删除资源
```bash
# 删除Pod
kubectl delete pod <pod-name>

# 删除Deployment
kubectl delete deployment <deployment-name>

# 通过YAML文件删除
kubectl delete -f deployment.yaml
```

## 5. 简单 YAML 示例

### 5.1 简单的 Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

### 5.2 Deployment 示例
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

### 5.3 Service 示例
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

## 6. 日常运维任务

### 6.1 检查集群健康状态
```bash
# 检查所有组件
kubectl get componentstatuses

# 检查节点状态
kubectl get nodes -o wide

# 检查所有Pod状态
kubectl get pods --all-namespaces
```

### 6.2 故障排查步骤
1. **查看Pod状态**：`kubectl get pods`
2. **查看Pod详情**：`kubectl describe pod <pod-name>`
3. **查看Pod日志**：`kubectl logs <pod-name>`
4. **检查事件**：`kubectl get events --sort-by='.lastTimestamp'`

### 6.3 常用技巧
- 使用 `-n <namespace>` 指定命名空间
- 使用 `-o wide` 查看更多信息
- 使用 `-w` 或 `--watch` 实时监控变化
- 使用 `--dry-run=client -o yaml` 生成YAML模板

## 7. 学习路径建议

1. **掌握基本概念**：Pod、Deployment、Service、Namespace
2. **熟练使用kubectl**：常用命令和参数
3. **理解YAML结构**：能够阅读和编写简单配置文件
4. **实践简单部署**：从单Pod到多副本Deployment
5. **学习服务暴露**：ClusterIP、NodePort、LoadBalancer

## 8. 注意事项

- 不要在生产环境直接使用 `kubectl run` 创建Pod（应使用Deployment）
- 注意资源限制，避免容器占用过多资源
- 定期清理未使用的资源
- 使用Namespace进行环境隔离

## 9. 下一步学习

完成本教程后，可以继续学习：
- 配置管理（ConfigMap、Secret）
- 存储管理（PersistentVolume、PersistentVolumeClaim）
- 网络策略
- 资源配额和限制

---

*本教程为入门级别，帮助你快速上手Kubernetes基础操作。在实际工作中，建议结合官方文档和实践经验逐步深入。*