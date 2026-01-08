# Kubernetes 端口完全解析

让我用清晰的图示和例子来解释 Kubernetes 中所有端口概念，这确实是初学者最容易混淆的部分。

## 端口关系总览

```
┌─────────────────────────────────────────────────────┐
│                Kubernetes 端口体系                   │
├─────────────────────────────────────────────────────┤
│          外部访问        │        内部访问            │
│  ┌──────────┐         │  ┌──────────┐             │
│  │ NodePort │         │  │ Cluster  │             │
│  │ 30000+   │         │  │ Port     │             │
│  └────┬─────┘         │  └────┬─────┘             │
│       │               │       │                   │
│       ▼               │       ▼                   │
│  ┌──────────────────────────────────────┐         │
│  │            Service                    │         │
│  │  type: NodePort/ClusterIP             │         │
│  └────┬──────┬──────────────┬───────────┘         │
│       │      │              │                     │
│       │      │              │                     │
│       ▼      ▼              ▼                     │
│  ┌────┴──────┴──────────────┴───────────┐       │
│  │  port  │  targetPort  │  nodePort     │       │
│  └───────────────────────────────────────┘       │
│       │              │                    │       │
│       │              │                    │       │
│       ▼              ▼                    ▼       │
│  ┌─────────────────────────────────────────────┐ │
│  │                  Pod                         │ │
│  │  ┌──────────────────────────────────────┐  │ │
│  │  │            Container                  │  │ │
│  │  │  containerPort: 8080                 │  │ │
│  │  └──────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## 五种核心端口详解

### 1. **containerPort**（容器端口）
**定义**：容器内应用程序实际监听的端口
**位置**：在 Pod 的容器定义中指定
**比喻**：公寓房间内的门牌号

```yaml
# 在 Pod/Deployment 定义中
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 8080  # ← 容器端口
```

**关键点**：
- 这是**应用程序实际监听的端口**
- 比如你的 Spring Boot 应用监听 8080，Nginx 监听 80
- 可选字段，但建议声明，有助于文档化

### 2. **targetPort**（目标端口）
**定义**：Service 要将流量转发到的 Pod 端口
**位置**：在 Service 定义中指定
**比喻**：快递员要把包裹送到哪个房间门牌号

```yaml
# 在 Service 定义中
apiVersion: v1
kind: Service
spec:
  ports:
  - port: 80
    targetPort: 8080  # ← 目标端口
```

**关键点**：
- 必须与 Pod 的 `containerPort` 匹配
- Service 通过这个端口访问 Pod
- 如果不指定，默认与 `port` 相同

### 3. **port**（Service 端口/集群端口）
**定义**：Service 在集群内部暴露的端口
**位置**：在 Service 定义中指定
**比喻**：公寓楼的总机号码

```yaml
apiVersion: v1
kind: Service
spec:
  type: ClusterIP
  ports:
  - port: 80  # ← Service端口
    targetPort: 8080
```

**关键点**：
- 集群内部通过 `service-name:port` 访问
- 其他 Pod 看到的端口
- 通常用 80、443 等标准端口

### 4. **nodePort**（节点端口）
**定义**：节点上暴露的静态端口
**位置**：在 NodePort 类型 Service 中指定
**比喻**：公寓楼的对外联系电话

```yaml
apiVersion: v1
kind: Service
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080  # ← 节点端口
```

**关键点**：
- 范围：30000-32767
- 可以从集群外部通过 `节点IP:nodePort` 访问
- 如果不指定，Kubernetes 会自动分配

### 5. **hostPort**（主机端口）
**定义**：Pod 直接绑定到宿主机的端口
**位置**：在 Pod 定义中指定
**比喻**：在公寓楼外墙上开个门

```yaml
# 在 Pod 定义中
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
      hostPort: 8080  # ← 主机端口
```

**关键点**：
- **不常用**，有局限性
- 每个节点只能运行一个使用该端口的 Pod
- 绕过 Service，Pod 直接对外暴露

## 完整示例

### 场景：部署一个 Web 应用
```yaml
# 1. Deployment 定义（定义容器）
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: web
        image: myapp:v1
        ports:
        - containerPort: 8080  # 容器内应用监听8080
---
# 2. Service 定义（ClusterIP类型，内部访问）
apiVersion: v1
kind: Service
metadata:
  name: webapp-internal
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
  - port: 80        # 集群内部访问端口
    targetPort: 8080 # 转发到容器的8080端口
---
# 3. Service 定义（NodePort类型，外部访问）
apiVersion: v1
kind: Service
metadata:
  name: webapp-external
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 80        # Service端口
    targetPort: 8080 # 目标端口
    nodePort: 30080  # 节点端口
```

## 端口映射关系图

```
外部用户访问:
    http://<任意节点IP>:30080
        │
        ▼ 节点监听30080端口
    ┌─────────────────┐
    │    NodePort     │
    │      30080      │
    └────────┬────────┘
             │
             ▼ 转换为Service端口
    ┌─────────────────┐
    │  Service Port   │
    │       80        │
    └────────┬────────┘
             │
             ▼ 负载均衡
    ┌─────────────────┐
    │   targetPort    │
    │      8080       │
    └────────┬────────┘
             │
             ▼ 进入容器
    ┌─────────────────┐
    │ containerPort   │
    │      8080       │
    └─────────────────┘
    应用收到请求
```

```
集群内部Pod访问:
    http://webapp-internal:80
        │
        ▼ DNS解析为ClusterIP
    ┌─────────────────┐
    │  Service Port   │
    │       80        │
    └────────┬────────┘
             │
             ▼ 负载均衡
    ┌─────────────────┐
    │   targetPort    │
    │      8080       │
    └────────┬────────┘
             │
             ▼ 进入容器
    ┌─────────────────┐
    │ containerPort   │
    │      8080       │
    └─────────────────┘
    应用收到请求
```

## 端口对应关系表格

| 端口类型 | 定义位置 | 访问者 | 访问方式 | 是否必填 | 示例 |
|---------|---------|--------|---------|---------|------|
| **containerPort** | Pod/Deployment | 应用程序自身 | 容器内监听 | 可选 | 8080 |
| **targetPort** | Service | Service | Service→Pod | 可选，默认同port | 8080 |
| **port** | Service | 集群内部Pod | Service端口 | 必填 | 80 |
| **nodePort** | NodePort Service | 外部用户 | 节点IP:端口 | 可选，自动分配 | 30080 |
| **hostPort** | Pod | 外部用户 | 节点IP:端口 | 可选 | 8080 |

## 不同访问方式对比

### 1. **容器内访问**（容器间通信）
```bash
# 在同一个Pod的不同容器间
localhost:8080

# 在不同Pod间（不推荐，用Service）
<POD_IP>:8080
```

### 2. **集群内访问**（通过Service）
```bash
# 通过Service名称
curl http://webapp-internal:80

# 通过ClusterIP
curl http://10.96.123.45:80
```

### 3. **集群外访问**
```bash
# 1. NodePort（最常用）
curl http://<任何节点IP>:30080

# 2. LoadBalancer（云服务商）
curl http://<云负载均衡器IP>:80

# 3. Ingress（推荐用于HTTP/HTTPS）
curl http://myapp.example.com
```

## 端口配置的最佳实践

### 1. **标准 Web 应用配置**
```yaml
# Deployment
containers:
- ports:
  - containerPort: 8080  # 应用实际端口

# Service
ports:
- port: 80              # 内部用80端口
  targetPort: 8080      # 转到容器的8080
```

### 2. **多端口 Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
  - name: metrics
    port: 9090
    targetPort: 9090
```

### 3. **验证端口配置**
```bash
# 查看Service详情
kubectl describe svc myapp
# 输出：
# Name:              myapp
# Type:              NodePort
# IP:                10.96.123.45
# Port:              http  80/TCP
# TargetPort:        8080/TCP
# NodePort:          http  30080/TCP
# Endpoints:         10.244.1.5:8080,10.244.2.3:8080

# 查看Endpoints
kubectl get endpoints myapp
# 输出：
# myapp    10.244.1.5:8080,10.244.2.3:8080

# 查看Pod的IP和端口
kubectl get pods -o wide
# 输出Pod IP

# 在集群内测试访问
kubectl run test --image=busybox --rm -it -- wget -O- http://myapp:80
```

## 常见问题与解答

### Q1: 为什么需要这么多端口？
**A1**: 为了解耦和灵活性：
- `containerPort`: 应用开发者决定
- `targetPort`: 运维可以灵活映射
- `port`: 集群内部标准端口
- `nodePort`: 外部访问入口

### Q2: 端口可以相同吗？
**A2**: 可以，但含义不同：
```yaml
ports:
- port: 80        # Service端口
  targetPort: 80  # 容器端口
# 表示容器内监听80，Service也用80
```

### Q3: 如何选择 nodePort？
**A3**: 
- 不指定：Kubernetes 自动分配（30000-32767）
- 指定：必须在 30000-32767 范围内
- 建议：让 Kubernetes 自动分配，除非有特殊需求

### Q4: hostPort vs nodePort
**A4**:
- **nodePort**: 每个节点都监听，流量通过 kube-proxy 转发
- **hostPort**: 只有运行 Pod 的节点监听，直接进入容器
- **推荐用 nodePort**，更灵活

## 记忆技巧

1. **从内到外思考**：
   ```
   应用监听什么端口？ → containerPort
   Service 转发到哪？ → targetPort
   集群内怎么访问？ → port
   集群外怎么访问？ → nodePort
   ```

2. **名称对应关系**：
   - `container` ←→ 容器
   - `target` ←→ 目标（Pod）
   - `port` ←→ Service
   - `node` ←→ 节点

3. **命令行检查**：
   ```bash
   # 检查所有端口配置
   kubectl describe svc <service-name>
   kubectl describe pod <pod-name>
   ```

记住这个核心原则：**Service 是中间人，它接收流量（port/nodePort），然后转发到正确的 Pod（targetPort），Pod 内的应用程序在特定端口（containerPort）上监听。**