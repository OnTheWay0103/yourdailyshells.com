# Kubernetes 高级教程：运维、监控、安全与集群管理

## 1. 集群运维与管理

### 1.1 节点管理

#### 节点维护模式
```bash
# 标记节点为不可调度
kubectl cordon <node-name>

# 排空节点（驱逐所有Pod）
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# 恢复节点调度
kubectl uncordon <node-name>
```

#### 节点故障处理
```bash
# 查看节点状态
kubectl get nodes -o wide

# 查看节点详情
kubectl describe node <node-name>

# 查看节点资源使用
kubectl top node <node-name>

# 查看节点事件
kubectl get events --field-selector involvedObject.kind=Node
```

### 1.2 集群升级策略

#### 升级流程
1. **备份集群状态**
   ```bash
   # 备份资源定义
   kubectl get all --all-namespaces -o yaml > cluster-backup.yaml

   # 备份etcd（如有访问权限）
   etcdctl snapshot save snapshot.db
   ```

2. **升级控制平面**
   ```bash
   # 升级kubeadm
   apt-get update && apt-get install -y kubeadm=1.28.0-00

   # 检查升级计划
   kubeadm upgrade plan

   # 执行升级
   kubeadm upgrade apply v1.28.0
   ```

3. **升级节点**
   ```bash
   # 排空节点
   kubectl drain <node-name> --ignore-daemonsets

   # 升级kubelet和kubectl
   apt-get update && apt-get install -y kubelet=1.28.0-00 kubectl=1.28.0-00

   # 重启kubelet
   systemctl restart kubelet

   # 恢复节点调度
   kubectl uncordon <node-name>
   ```

### 1.3 集群备份与恢复（Velero）

#### 安装Velero
```bash
# 安装Velero客户端
wget https://github.com/vmware-tanzu/velero/releases/download/v1.11.0/velero-v1.11.0-linux-amd64.tar.gz
tar -xvf velero-v1.11.0-linux-amd64.tar.gz
sudo mv velero-v1.11.0-linux-amd64/velero /usr/local/bin/

# 配置Velero（以AWS为例）
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.7.0 \
  --bucket my-backup-bucket \
  --backup-location-config region=us-west-2 \
  --snapshot-location-config region=us-west-2 \
  --secret-file ./credentials-velero
```

#### 备份和恢复操作
```bash
# 创建备份
velero backup create cluster-backup --include-namespaces=default,production

# 定期备份
velero schedule create daily-backup --schedule="0 2 * * *" --include-namespaces=default

# 恢复备份
velero restore create --from-backup cluster-backup

# 查看备份状态
velero backup describe cluster-backup
```

## 2. 监控与告警

### 2.1 Prometheus + Grafana 监控栈

#### 安装Prometheus Operator
```bash
# 添加Helm仓库
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 安装kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin
```

#### 自定义监控规则
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: k8s-alerts
  namespace: monitoring
spec:
  groups:
  - name: kubernetes.rules
    rules:
    - alert: HighMemoryUsage
      expr: (sum(container_memory_working_set_bytes{container!="", pod!=""}) by (pod) / sum(kube_pod_container_resource_limits_memory_bytes) by (pod)) * 100 > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.pod }} 内存使用率超过80%"

    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[5m]) * 60 * 5 > 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Pod {{ $labels.pod }} 在5分钟内重启超过5次"
```

### 2.2 日志收集（EFK Stack）

#### 安装Elasticsearch、Fluentd、Kibana
```bash
# 安装Elasticsearch
helm install elasticsearch elastic/elasticsearch --namespace logging

# 安装Fluentd
kubectl apply -f https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch.yaml

# 安装Kibana
helm install kibana elastic/kibana --namespace logging --set service.type=NodePort
```

#### Fluentd配置
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>

    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      logstash_format true
      logstash_prefix fluentd
    </match>
```

## 3. 安全加固

### 3.1 RBAC（基于角色的访问控制）

#### 创建ServiceAccount
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ci-service-account
  namespace: default
```

#### 定义Role和RoleBinding
```yaml
# Role（命名空间级别）
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager
  namespace: default
rules:
- apiGroups: ["apps", "extensions"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-manager
subjects:
- kind: ServiceAccount
  name: ci-service-account
  namespace: default
```

#### 定义ClusterRole和ClusterRoleBinding
```yaml
# ClusterRole（集群级别）
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-viewer
rules:
- apiGroups: [""]
  resources: ["nodes", "persistentvolumes"]
  verbs: ["get", "list", "watch"]

# ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewer-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-viewer
subjects:
- kind: Group
  name: "viewers"
  apiGroup: rbac.authorization.k8s.io
```

### 3.2 Pod安全策略（PodSecurityPolicy）

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
```

### 3.3 网络策略（NetworkPolicy）

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### 3.4 安全上下文（SecurityContext）

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: sec-ctx-demo
    image: busybox:1.28
    command: [ "sh", "-c", "sleep 1h" ]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
      runAsNonRoot: true
```

## 4. 服务网格（Istio）

### 4.1 安装Istio
```bash
# 下载Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# 安装Istio
istioctl install --set profile=demo -y

# 启用自动注入
kubectl label namespace default istio-injection=enabled
```

### 4.2 流量管理
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews-route
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 90
    - destination:
        host: reviews
        subset: v2
      weight: 10

---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: reviews-destination
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

### 4.3 安全策略
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT

---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
spec:
  selector:
    matchLabels:
      app: api
  rules:
  - from:
    - source:
        requestPrincipals: ["*"]
    to:
    - operation:
        methods: ["GET", "POST"]
```

## 5. GitOps（ArgoCD）

### 5.1 安装ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 获取初始密码
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 端口转发访问UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 5.2 应用部署
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/myapp.git
    targetRevision: HEAD
    path: k8s/
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## 6. 性能优化

### 6.1 集群性能调优

#### 节点资源预留
```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
systemReserved:
  cpu: "500m"
  memory: "1Gi"
  ephemeral-storage: "5Gi"
kubeReserved:
  cpu: "250m"
  memory: "2Gi"
  ephemeral-storage: "5Gi"
evictionHard:
  memory.available: "500Mi"
  nodefs.available: "10%"
```

#### Pod调度优化
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: optimized-pod
spec:
  # 节点亲和性
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd

  # Pod亲和性
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - cache
        topologyKey: kubernetes.io/hostname

  # Pod反亲和性
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - web
          topologyKey: kubernetes.io/hostname

  # 容忍度
  tolerations:
  - key: "node.kubernetes.io/unreachable"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 6000
```

### 6.2 应用性能优化

#### 资源QoS（服务质量）
- **Guaranteed**：设置了相等的requests和limits
- **Burstable**：设置了requests，limits可选
- **BestEffort**：未设置requests和limits

#### 多容器资源分配
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: main-app
    image: myapp:latest
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "1"
        memory: "1Gi"

  - name: sidecar
    image: sidecar:latest
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "200m"
        memory: "256Mi"

  # 共享资源策略
  shareProcessNamespace: true
```

## 7. 故障排除高级技巧

### 7.1 诊断工具套件

#### 安装调试工具
```bash
# 网络诊断
kubectl run netshoot --image=nicolaka/netshoot -it --rm --restart=Never -- /bin/bash

# 性能分析
kubectl run perf-tools --image=brendangregg/perf-tools -it --rm --privileged

# 安全扫描
kubectl run trivy --image=aquasec/trivy -it --rm -- trivy image nginx:latest
```

### 7.2 核心组件故障排查

#### API Server故障
```bash
# 检查API Server状态
kubectl get componentstatuses

# 查看API Server日志
journalctl -u kube-apiserver -f

# 检查证书有效期
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates
```

#### etcd故障
```bash
# 检查etcd集群健康
etcdctl endpoint health

# 检查etcd成员
etcdctl member list

# 检查etcd存储
etcdctl get / --prefix --keys-only | head -20
```

#### 网络插件故障
```bash
# 检查CNI插件
kubectl get pods -n kube-system | grep -E '(calico|flannel|cilium)'

# 检查网络策略
kubectl get networkpolicies -A

# 诊断网络连通性
kubectl run network-test --image=alpine -it --rm -- sh -c "ping google.com"
```

### 7.3 高级调试命令

```bash
# 查看资源的最后状态
kubectl get <resource> <name> -o yaml --export

# 查看资源变更历史
kubectl rollout history deployment/<deployment-name>

# 查看资源版本差异
kubectl diff -f deployment.yaml

# 模拟Pod调度
kubectl create -f pod.yaml --dry-run=server --output=yaml | kubectl apply -f -

# 检查准入控制器
kubectl get validatingwebhookconfigurations, mutatingwebhookconfigurations
```

## 8. 多集群管理

### 8.1 集群联邦（Kubernetes Federation）

#### 安装Kubefed
```bash
# 安装kubefed
wget https://github.com/kubernetes-sigs/kubefed/releases/download/v0.9.2/kubefedctl-0.9.2-linux-amd64.tgz
tar -xzf kubefedctl-0.9.2-linux-amd64.tgz
sudo mv kubefedctl /usr/local/bin/

# 初始化集群联邦
kubefed init k8s-federation \
  --host-cluster-context=cluster1 \
  --dns-provider=aws-route53 \
  --dns-zone-name=example.com
```

#### 联邦资源管理
```yaml
apiVersion: types.kubefed.io/v1beta1
kind: FederatedDeployment
metadata:
  name: federated-deployment
  namespace: default
spec:
  template:
    metadata:
      labels:
        app: federated-app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: federated-app
      template:
        metadata:
          labels:
            app: federated-app
        spec:
          containers:
          - name: nginx
            image: nginx:latest
  placement:
    clusters:
    - name: cluster1
    - name: cluster2
  overrides:
  - clusterName: cluster1
    clusterOverrides:
    - path: "/spec/replicas"
      value: 5
```

## 9. 成本优化

### 9.1 资源使用分析
```bash
# 安装kube-cost
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace

# 查看资源使用情况
kubectl top pods --all-namespaces --sort-by=cpu
kubectl top pods --all-namespaces --sort-by=memory

# 分析未使用资源
kubectl get deployments --all-namespaces -o json | jq '.items[] | select(.spec.replicas > 0) | .metadata.name'
```

### 9.2 自动伸缩优化
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: optimized-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: optimized-deployment
  minReplicas: 2
  maxReplicas: 20
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 65
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
```

## 10. 持续学习和社区资源

### 10.1 认证和培训
- **CKA（Certified Kubernetes Administrator）**
- **CKAD（Certified Kubernetes Application Developer）**
- **CKS（Certified Kubernetes Security Specialist）**

### 10.2 重要资源
- **官方文档**：https://kubernetes.io/docs/
- **Kubernetes GitHub**：https://github.com/kubernetes/kubernetes
- **Kubernetes Slack**：slack.k8s.io
- **Kubernetes 博客**：https://kubernetes.io/blog/

### 10.3 监控社区动态
```bash
# 关注Kubernetes版本发布
kubectl version --short

# 查看即将弃用的API版本
kubectl api-resources --api-group=apps -o wide

# 检查集群兼容性
kubectl get --raw /version
```

## 11. 总结

作为Kubernetes高级运维人员，你需要掌握：

1. **深度集群管理**：升级、备份、恢复、多集群管理
2. **全面监控告警**：Prometheus、Grafana、EFK栈
3. **安全加固**：RBAC、网络策略、Pod安全策略
4. **服务网格**：Istio流量管理、安全、可观测性
5. **GitOps实践**：ArgoCD自动化部署
6. **性能优化**：资源调度、QoS、成本控制
7. **高级故障排除**：核心组件调试、网络诊断

---

*Kubernetes生态系统不断发展，建议保持学习态度，关注社区动态，结合实际工作经验不断优化运维实践。*