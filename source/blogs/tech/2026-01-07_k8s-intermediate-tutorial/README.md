# Kubernetes 中级教程：深入部署、网络和配置管理

## 1. 高级部署策略

### 1.1 滚动更新（Rolling Update）
- 逐步替换旧Pod，确保零停机
- 可控制更新速度和最大不可用Pod数

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # 最多可超出期望副本数1个
      maxUnavailable: 0    # 更新期间不可用Pod数为0
  replicas: 3
  # ... 其他配置
```

### 1.2 蓝绿部署（Blue-Green Deployment）
- 维护两套完全相同环境（蓝、绿）
- 通过Service切换流量

```bash
# 创建绿色部署
kubectl apply -f green-deployment.yaml

# 切换Service指向绿色部署
kubectl patch service my-service -p '{"spec":{"selector":{"version":"green"}}}'
```

### 1.3 金丝雀发布（Canary Release）
- 逐步将流量导入新版本
- 监控新版本稳定性

```yaml
# 主部署（90%流量）
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main-deployment
spec:
  replicas: 9
  selector:
    matchLabels:
      app: myapp
      version: stable

# 金丝雀部署（10%流量）
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      version: canary
```

## 2. 服务网络深入

### 2.1 Service 类型详解

#### ClusterIP（默认）
- 集群内部IP地址
- 只能集群内访问

```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-service
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

#### NodePort
- 在每个节点上开放静态端口
- 节点IP:NodePort 可外部访问

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30007  # 30000-32767
```

#### LoadBalancer
- 云提供商负载均衡器
- 自动分配外部IP

```yaml
apiVersion: v1
kind: Service
metadata:
  name: loadbalancer-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

### 2.2 Ingress
- HTTP/HTTPS路由管理
- 基于主机名或路径的路由

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### 2.3 NetworkPolicy
- Pod网络隔离
- 定义入口和出口规则

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      role: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
    ports:
    - protocol: TCP
      port: 6379
```

## 3. 配置管理

### 3.1 ConfigMap 高级用法

#### 创建ConfigMap
```bash
# 从文件创建
kubectl create configmap app-config --from-file=config.properties

# 从目录创建
kubectl create configmap app-config --from-file=config/

# 从字面值创建
kubectl create configmap app-config \
  --from-literal=log.level=INFO \
  --from-literal=server.port=8080
```

#### 使用ConfigMap
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    # 作为环境变量
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log.level
    # 作为文件挂载
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### 3.2 Secret 管理

#### 创建Secret
```bash
# 通用Secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123

# TLS Secret
kubectl create secret tls tls-secret \
  --cert=cert.pem \
  --key=key.pem

# Docker镜像Secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=admin \
  --docker-password=secret123 \
  --docker-email=admin@example.com
```

#### 使用Secret
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
  imagePullSecrets:
  - name: regcred
```

## 4. 存储管理

### 4.1 PersistentVolume (PV) 和 PersistentVolumeClaim (PVC)

#### 静态配置
```yaml
# PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteMany
  nfs:
    server: nfs-server.example.com
    path: "/exports/data"

# PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```

#### 动态配置（StorageClass）
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 20Gi
```

### 4.2 使用存储
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-storage
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        volumeMounts:
        - name: data-volume
          mountPath: /data
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: pvc-nfs
```

## 5. 资源管理

### 5.1 资源请求和限制
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: app
    image: myapp:latest
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### 5.2 ResourceQuota（资源配额）
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
    services: "5"
```

### 5.3 LimitRange（限制范围）
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```

## 6. 自动伸缩

### 6.1 Horizontal Pod Autoscaler (HPA)
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 6.2 基于自定义指标的HPA
```bash
# 安装metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 创建HPA
kubectl autoscale deployment app-deployment \
  --cpu-percent=70 \
  --min=2 \
  --max=10
```

## 7. 工作负载管理

### 7.1 StatefulSet
- 有状态应用管理
- 稳定的网络标识和持久存储

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### 7.2 DaemonSet
- 每个节点运行一个Pod副本
- 用于日志收集、监控等

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

### 7.3 Job 和 CronJob
```yaml
# Job
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo Processing item $ITEM"]
      restartPolicy: Never

# CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cronjob
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
          restartPolicy: OnFailure
```

## 8. 运维工具和技巧

### 8.1 标签和选择器
```bash
# 添加标签
kubectl label pods my-pod environment=production

# 根据标签筛选
kubectl get pods -l environment=production

# 更新标签
kubectl label pods my-pod environment=staging --overwrite

# 删除标签
kubectl label pods my-pod environment-
```

### 8.2 注解（Annotations）
```bash
# 添加注解
kubectl annotate pods my-pod \
  description="Main application pod" \
  last-modified="2024-01-01"

# 查看注解
kubectl describe pod my-pod | grep Annotations
```

### 8.3 字段选择器
```bash
# 根据状态筛选
kubectl get pods --field-selector status.phase=Running

# 根据节点筛选
kubectl get pods --field-selector spec.nodeName=node-1
```

## 9. 调试和故障排除

### 9.1 高级调试命令
```bash
# 查看Pod事件
kubectl describe pod <pod-name>

# 查看集群事件
kubectl get events --sort-by='.lastTimestamp' -A

# 端口转发
kubectl port-forward pod/<pod-name> 8080:80

# 临时调试容器
kubectl debug pod/<pod-name> -it --image=busybox

# 网络诊断
kubectl run network-check --image=nicolaka/netshoot -it --rm
```

### 9.2 常见问题排查

#### Pod一直处于Pending状态
1. 检查资源配额：`kubectl describe pod <pod-name>`
2. 检查节点资源：`kubectl describe node <node-name>`
3. 检查污点和容忍度

#### Pod不断重启
1. 查看日志：`kubectl logs <pod-name> --previous`
2. 检查就绪性和存活探针配置
3. 检查资源限制

#### 服务无法访问
1. 检查Service选择器是否匹配Pod标签
2. 检查网络策略
3. 检查防火墙规则

## 10. 最佳实践

1. **使用Deployment而非裸Pod**
2. **为容器设置资源限制**
3. **使用命名空间进行环境隔离**
4. **为生产环境配置就绪性和存活探针**
5. **使用ConfigMap和Secret管理配置**
6. **实施网络策略进行安全隔离**
7. **定期清理未使用的资源**

## 11. 下一步学习

完成中级教程后，建议学习：
- 服务网格（Istio、Linkerd）
- GitOps（ArgoCD、Flux）
- 安全策略（Pod Security Standards）
- 集群备份和恢复（Velero）

---

*本教程涵盖Kubernetes中级主题，帮助你掌握生产环境中的核心功能。建议在实际项目中逐步实践这些概念。*