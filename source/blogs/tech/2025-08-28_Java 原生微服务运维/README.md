# Java 原生微服务运维

---

### **Java 原生微服务运维实践文档**

**文档版本：** 1.0
**最后更新日期：** 2025-08-28
**目标读者：** 运维工程师、开发工程师、SRE、技术经理

---

#### **1. 引言**

1.1. 文档目的
本文档旨在规范基于 Java 技术栈的微服务应用的运维标准、流程和最佳实践，确保微服务架构的稳定性、可观测性、可伸缩性和安全性，提升整体系统的运维效率。

1.2. 适用范围
所有采用 Spring Boot、Spring Cloud 等框架开发的 Java 微服务项目。

1.3. 运维理念
*   **自动化先行：** 所有重复性工作应尽可能自动化。
*   **基础设施即代码 (IaC)：** 使用代码（如 Terraform, Ansible）定义和管理基础设施。 <!--有用过Ansible，目前工具不确定-->
*   **不可变基础设施：** 服务器部署后不再修改，而是通过替换镜像进行更新。
*   **DevOps 文化：** 开发与运维紧密协作，共同对服务的整个生命周期负责。

---

#### **2. 环境与工具链**

2.1. 环境划分
*   **开发环境 (Development)：** 用于本地开发调试。
*   **测试环境 (Testing)：** 用于自动化测试、集成测试、SIT。
*   **预发布环境 (Staging)：** 尽可能模拟生产环境，用于最终验收和性能压测。
*   **生产环境 (Production)：** 线上用户使用的环境。

2.2. 核心工具链
*   **代码管理：** Git (GitLab) <!--新老两套库，每周移动盘备份-->
*   **CI/CD：** Jenkins, GitLab CI, GitHub Actions <!--Jenkins，相关shell文件和配置-->
*   **构建工具：** Maven, Gradle <!--服务端maven, 前端有gradle, xcode等，打包机器设备所在地与管理-->
*   **容器化：** Docker <!--生产环境的docker, 开发测试环境的本地docker以及docker相关操作 -->
*   **镜像仓库：** Harbor, Docker Registry <!-- 阿里云镜像源 -->
*   **编排调度：** Kubernetes (K8s) - **主流推荐** 或 Docker Swarm <!-- k8s的操作，不同环境的k8s -->
*   **服务治理：** Spring Cloud Alibaba, Consul, Nacos (服务发现/配置中心) <!-- Nacos -->
*   **监控告警：** Prometheus + Grafana, SkyWalking, ELK (Elasticsearch, Logstash, Kibana)
*   **基础设施：** Terraform, Ansible
*   **其他设施：** yearning, xxjob, contab,appllo,nexus,k8s调度平台..

---

#### **3. 开发与构建规范**

3.1. 应用配置
*   严格区分 `application-dev.yml`, `application-test.yml`, `application-prod.yml`。
*   **禁止** 将敏感信息（密码、密钥）硬编码在配置文件中。使用配置中心（Nacos, Apollo）或 Kubernetes Secrets 管理。
*   所有配置必须有默认值，且支持环境变量覆盖（Cloud Native 最佳实践）。

3.2. 健康检查端点
*   必须启用并暴露 Spring Boot Actuator 的 `/actuator/health` 端点。
*   配置 `liveness`（是否存活）和 `readiness`（是否就绪）探针，供 K8s 使用。

3.3. 日志规范
*   使用 SLF4J + Logback/Log4j2 作为日志框架。
*   **日志格式：** 采用 JSON 格式输出，便于 ELK 收集和解析。
*   **日志内容：** 必须包含唯一追踪ID（如 `traceId` 和 `spanId`，可通过 Sleuth 实现），串联一次请求的所有链路。
*   **日志级别：** 合理使用 `INFO`, `WARN`, `ERROR`。生产环境默认 `INFO`，避免过多的 `DEBUG` 日志。

3.4. 容器化 (Dockerfile)
*   使用多阶段构建，减小镜像体积。
*   基础镜像推荐使用官方的 `eclipse-temurin:17-jre-alpine`（轻量级）。
*   容器内应用应以非 root 用户运行。
*   设置合理的环境变量、工作目录和暴露端口。

**示例 Dockerfile:**
```dockerfile
FROM eclipse-temurin:17-jre-alpine as builder
WORKDIR /app
COPY target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring
WORKDIR /app
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
EXPOSE 8080
```

---

#### **4. 部署与发布策略**

4.1. Kubernetes 资源定义
*   使用 YAML 文件定义所有部署资源：Deployment, Service, Ingress, ConfigMap, Secret 等。
*   资源请求与限制：必须为每个容器设置 `resources.requests` 和 `resources.limits`（CPU 和 Memory）。

4.2. 发布策略 <!-- 目前采用滚动更新 -->
*   **蓝绿部署：** 准备一套新环境，流量一次性切换。需要额外的资源，回滚快。
*   **金丝雀发布：** 将部分流量导入新版本，验证无误后逐步扩大范围。是风险较低的策略。
*   **滚动更新：** K8s 默认策略，逐步替换 Pod。可配置 `maxSurge` 和 `maxUnavailable`。

---

#### **5. 监控与告警**

5.1. 指标监控 (Metrics - Prometheus)
*   **JVM 监控：** 内存使用（堆/非堆）、GC 次数与时间、线程状态、CPU 使用率。
*   **应用监控：** HTTP 请求 QPS、响应时间、错误率（4xx, 5xx）。
*   **中间件监控：** 数据库连接池、Redis 缓存命中率、MQ 堆积情况。
*   **业务监控：** 关键业务指标（如订单创建成功率）。
*   **可视化：** 使用 Grafana 绘制监控大盘。

5.2. 日志管理 (Logging - ELK)
*   所有应用日志标准输出，由 DaemonSet（如 Filebeat）收集并发送至 ELK。
*   建立关键错误日志的告警规则（例如，10分钟内 ERROR 日志出现超过 20 次则告警）。 <!-- 告警的规则设置？ -->

5.3. 链路追踪 (Tracing - SkyWalking/Zipkin)
*   集成链路追踪工具，追踪一次请求经过的所有微服务，用于性能分析和故障排查。 <!-- SkyWalking的使用 -->

5.4. 告警管理
*   告警分级：P0（紧急）、P1（高）、P2（中）、P3（低）。
*   告警渠道：邮件、钉钉、企业微信、短信（仅限 P0/P1）。
*   **告警原则：** 必须可行动、准确，避免告警风暴。设置合理的静默时间和阈值。 <!-- 告警的规则设置？服务，域名，证书等 -->

---

#### **6. 高可用与弹性**

6.1. 容错处理
*   **服务熔断：** 使用 Resilience4j 或 Sentinel，防止下游服务故障导致上游服务雪崩。 <!-- Sentinel的使用 -->
*   **服务降级：** 在系统压力过大时，关闭非核心功能，保障主链路畅通。
*   **超时与重试：** 为所有外部调用（HTTP、RPC）设置合理的超时时间和重试策略。

6.2. 流量治理
*   使用 API 网关（Spring Cloud Gateway）进行限流、鉴权、路由。  <!-- ？ -->
*   在 K8s 中可使用 Ingress Controller 进行七层流量管理。

---

#### **7. 安全**

7.1. 基础设施安全
*   K8s RBAC 权限最小化原则。
*   定期扫描镜像漏洞（Harbor 集成 Trivy/Clair）。
*   使用网络策略（NetworkPolicy）控制 Pod 间网络流量。

7.2. 应用安全
*   **API 安全：** 接口鉴权（JWT/OAuth2）、防 SQL 注入、XSS、CSRF 攻击。
*   **通信安全：** 内部服务间通信使用 mTLS（可通过 Service Mesh 如 Istio 实现）。
*   **秘密管理：** 使用 Kubernetes Secrets 或外部 Vault 管理密码、令牌、证书。

---

#### **8. 日常运维与故障处理**

8.1. 日常操作
*   **日志查询：** 使用 Kibana 根据 `traceId`、服务名、时间范围检索日志。
*   **性能分析：** 使用 `jstack` 分析线程阻塞，`jmap` 分析内存泄漏。
*   **容器调试：** `kubectl logs -f <pod_name>`, `kubectl exec -it <pod_name> -- bash`。

8.2. 故障排查流程
1.  **确认现象：** 通过监控大盘确认影响范围（哪个服务、什么指标异常）。
2.  **定位问题：**
    *   检查告警信息。
    *   查看应用日志和链路追踪，找到错误根源。
    *   检查系统资源（CPU、内存、磁盘、网络）。
3.  **恢复服务：** 优先考虑重启实例、扩容或回滚版本以快速恢复。
4.  **根因分析：** 事后进行详细的根因分析（RCA），并记录文档，避免再次发生。

---

#### **9. 数据管理与持久化**

*   **数据库运维：** 主从复制、备份恢复、慢查询优化。 <!-- 服务与备份的硬盘容量监控？ -->
*   **状态分离：** 应用本身应无状态，所有状态数据存储到外部数据库、缓存或对象存储中。

---

#### **10. 灾难恢复**

*   制定完善的备份策略（应用代码、数据库、配置文件）。
*   建立跨可用区（AZ）甚至跨地域（Region）的灾备方案。
*   定期进行灾备演练。

---

#### **附录**

*   A. 常用命令手册 (kubectl, docker, jvm)
*   B. 示例配置文件
*   C. 变更管理流程
*   D. 术语表
*   