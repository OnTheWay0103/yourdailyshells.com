# K8S云原生微服务项目之混合模式Docker开发环境本地配置指南

## 概述

混合模式Docker开发环境是一种结合了本地代码开发和远程数据源的开发模式。这种模式允许开发者在本地修改和调试代码，同时使用远程开发环境的数据库和其他依赖服务，从而获得真实的数据环境，避免了数据同步的复杂性。

## 优势

- **真实数据**：使用开发环境的真实数据，避免数据不一致问题
- **快速开发**：无需导入或同步大量测试数据
- **环境一致性**：本地测试结果与开发环境一致
- **专注代码**：只关注代码修改，而不是环境配置
- **灵活调试**：可以随时修改代码并快速验证效果

## 配置步骤

### 1. 创建Docker配置文件

#### Dockerfile.local

```dockerfile
FROM maven:3.8-openjdk-8 AS builder

# 设置工作目录
WORKDIR /build

# 复制父pom.xml
COPY pom.xml /build/pom.xml

# 复制子模块
COPY module1 /build/module1/
COPY module2 /build/module2/
# ... 其他模块

# 设置版本变量
ENV REVISION=x.y.z

# 构建应用
RUN mvn clean package -DskipTests -Drevision=$REVISION

# 运行阶段
FROM openjdk:8-jre-alpine

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 设置工作目录
WORKDIR /app

# 从构建阶段复制JAR文件
COPY --from=builder /build/main-module/target/*.jar /app/app.jar

# 暴露端口
EXPOSE 8080

# 设置JVM参数
ENV JAVA_OPTS="-XX:+UseG1GC -Xms512m -Xmx1g"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar --spring.profiles.active=docker"]
```

#### docker-compose.yml

```yaml
version: '3'

services:
  # 应用服务
  app-service:
    image: openjdk:8-jre-alpine
    container_name: your-app-service
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_MAIN_ALLOW_CIRCULAR_REFERENCES=true
      - SPRING_MAIN_ALLOW_BEAN_DEFINITION_OVERRIDING=true
    volumes:
      - ./logs:/data/logs
      - ./main-module/target:/app
      - ./scripts/docker-entrypoint.sh:/docker-entrypoint.sh
    networks:
      - app-network
    working_dir: /app
    entrypoint: ["/docker-entrypoint.sh"]

  # 本地MongoDB（可选，实际可能使用远程服务）
  mongodb:
    image: mongo:4.2
    container_name: your-mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    networks:
      - app-network

  # 本地Redis（可选，实际可能使用远程服务）
  redis:
    image: redis:6.0
    container_name: your-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mongodb_data:
  redis_data:
```

### 2. 创建Docker入口脚本

#### scripts/docker-entrypoint.sh

```bash
#!/bin/sh

# 创建日志目录
mkdir -p /data/logs

# 显示环境变量
echo "Environment variables:"
echo "SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE"
echo "JAVA_OPTS: $JAVA_OPTS"

# 显示配置文件
echo "Checking application-docker.properties..."
cat /app/classes/application-docker.properties

# 确保循环引用配置生效
export SPRING_MAIN_ALLOW_CIRCULAR_REFERENCES=true
echo "Setting SPRING_MAIN_ALLOW_CIRCULAR_REFERENCES=true"

# 启动应用
echo "Starting application..."
java -XX:+UseG1GC -Xms512m -Xmx1g -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/data/logs/ \
  -Dspring.main.allow-circular-references=true \
  -Dspring.main.allow-bean-definition-overriding=true \
  -jar /app/your-application.jar \
  --spring.profiles.active=docker \
  --logging.file.path=/data/logs \
  --logging.file.name=/data/logs/application.log
```

### 3. 创建应用配置文件

#### application-docker.properties

```properties
# ========================================
# Docker环境配置
# ========================================

# 基础配置
server.port=8080
spring.application.name=your-service
spring.main.allow-circular-references=true
spring.main.allow-bean-definition-overriding=true

# ========================================
# 数据库配置 - 使用服务名连接Docker容器
# ========================================
# 这些配置会被Apollo覆盖，指向远程服务器
spring.data.mongodb.host=mongodb
spring.data.mongodb.port=27017
spring.data.mongodb.database=your_database

# ========================================
# Redis配置 - 使用服务名连接Docker容器
# ========================================
# 这些配置会被Apollo覆盖，指向远程服务器
spring.redis.host=redis
spring.redis.port=6379
spring.redis.database=0
spring.redis.timeout=2000ms

# ========================================
# Apollo配置中心 - 连接远程配置中心
# ========================================
apollo.bootstrap.enabled=true
apollo.bootstrap.eagerLoad.enabled=true
apollo.autoUpdateInjectedSpringProperties=true
# Apollo配置中心地址
apollo.meta=http://your-apollo-config-server
# 应用ID
app.id=your-service-id
# 命名空间配置
apollo.bootstrap.namespaces=application,datasource,other-configs
```

### 4. 创建启动和停止脚本

#### scripts/start-docker-env.sh

```bash
#!/bin/bash

# ========================================
# Docker环境启动脚本
# ========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查Docker和Docker Compose是否安装
check_docker() {
    log_step "检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker服务未启动或无权限访问"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    log_info "Docker环境检查通过"
}

# 构建并启动Docker容器
start_containers() {
    log_step "启动Docker容器..."
    
    # 创建日志目录
    mkdir -p logs
    
    # 构建并启动容器
    docker-compose up -d --build
    
    if [ $? -eq 0 ]; then
        log_info "容器启动成功"
    else
        log_error "容器启动失败"
        exit 1
    fi
}

# 等待服务就绪
wait_for_service() {
    log_step "等待服务就绪..."
    
    for i in {1..30}; do
        if curl -s http://localhost:8080/actuator/health > /dev/null; then
            log_info "服务已就绪"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    log_error "服务启动超时"
    return 1
}

# 显示服务状态
show_status() {
    log_step "服务状态检查..."
    
    echo ""
    echo "========================================="
    echo "           Docker容器状态"
    echo "========================================="
    docker-compose ps
    echo "========================================="
    echo ""
    
    echo "API测试地址:"
    echo "  - 健康检查: http://localhost:8080/actuator/health"
    echo "  - API示例:  http://localhost:8080/api/example"
    echo ""
    echo "日志查看命令:"
    echo "  - 应用服务: docker logs -f your-app-service"
    echo "  - MongoDB: docker logs -f your-mongodb"
    echo "  - Redis:   docker logs -f your-redis"
}

# 主函数
main() {
    log_info "开始启动Docker环境..."
    
    check_docker
    start_containers
    wait_for_service
    show_status
    
    log_info "Docker环境启动完成！"
    log_info "可以使用 'docker-compose logs -f' 查看所有容器日志"
}

# 如果直接执行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

#### scripts/stop-docker-env.sh

```bash
#!/bin/bash

# ========================================
# Docker环境停止脚本
# ========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 停止Docker容器
stop_containers() {
    log_step "停止Docker容器..."
    
    docker-compose down
    
    if [ $? -eq 0 ]; then
        log_info "容器停止成功"
    else
        log_error "容器停止失败"
        exit 1
    fi
}

# 清理数据卷
clean_volumes() {
    log_step "清理数据卷..."
    
    docker volume rm $(docker volume ls -q | grep -E 'mongodb_data|redis_data') 2>/dev/null || true
    
    log_info "数据卷清理完成"
}

# 主函数
main() {
    log_info "开始停止Docker环境..."
    
    stop_containers
    
    # 如果指定了--clean-volumes参数，则清理数据卷
    if [[ "$1" == "--clean-volumes" ]]; then
        clean_volumes
    fi
    
    log_info "Docker环境已停止！"
}

# 如果直接执行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 开发工作流

### 1. 初始设置

1. 确保已安装Docker和Docker Compose
2. 克隆项目代码库
3. 编译项目：`mvn clean package -DskipTests`
4. 启动Docker环境：`./scripts/start-docker-env.sh`

### 2. 日常开发流程

1. 修改Java代码
2. 编译项目：`mvn clean package -DskipTests`
3. 重启服务容器：`docker restart your-app-service`
4. 查看日志：`docker logs -f your-app-service`
5. 测试API：使用Postman或curl测试接口

### 3. 调试技巧

1. **查看日志**：
   ```bash
   docker logs -f your-app-service
   ```

2. **进入容器**：
   ```bash
   docker exec -it your-app-service sh
   ```

3. **检查配置**：
   ```bash
   docker exec -it your-app-service cat /app/classes/application-docker.properties
   ```

4. **查看数据库连接**：
   ```bash
   docker exec -it your-app-service env | grep MONGO
   docker exec -it your-app-service env | grep REDIS
   ```

## 混合模式的关键配置

### 1. Apollo配置中心

Apollo配置中心是实现混合模式的关键，它允许应用在运行时获取远程配置，覆盖本地配置。

```properties
# Apollo配置
apollo.bootstrap.enabled=true
apollo.bootstrap.eagerLoad.enabled=true
apollo.meta=http://your-apollo-config-server
app.id=your-service-id
```

### 2. 数据源配置覆盖

Apollo会覆盖本地的数据源配置，指向远程开发环境：

```properties
# 这些配置会被Apollo覆盖
spring.data.mongodb.host=192.168.x.x
spring.data.mongodb.port=27017
spring.data.mongodb.username=dev_user
spring.data.mongodb.password=dev_password

spring.redis.host=192.168.x.x
spring.redis.port=6379
spring.redis.password=dev_password
```

### 3. 环境变量控制

使用环境变量控制应用行为：

```bash
# 在docker-compose.yml中设置
environment:
  - SPRING_PROFILES_ACTIVE=docker
  - FEATURE_FLAG_ENABLE=false
```

## 常见问题与解决方案

### 1. 循环依赖问题

**问题**：Spring应用启动时报循环依赖错误

**解决方案**：
- 启用循环引用允许：`spring.main.allow-circular-references=true`
- 创建条件Bean提供空实现：

```java
@Configuration
public class DockerConfig {
    @Bean
    @Primary
    @ConditionalOnProperty(name = "feature.enable", havingValue = "false")
    public SomeService emptySomeService() {
        return new SomeService() {
            @Override
            public void doSomething() {
                // 空实现
            }
        };
    }
}
```

### 2. 端口冲突

**问题**：本地端口已被占用

**解决方案**：
- 修改docker-compose.yml中的端口映射
- 使用随机端口：`dubbo.protocol.port=-1`

### 3. 远程服务连接失败

**问题**：无法连接到远程开发环境的服务

**解决方案**：
- 检查网络连接和VPN设置
- 确认远程服务IP和端口是否正确
- 检查防火墙设置

## 最佳实践

1. **配置分离**：将环境特定的配置放在专用的配置文件中
2. **日志级别**：开发环境使用DEBUG日志级别以获取更多信息
3. **健康检查**：实现完善的健康检查接口，便于监控服务状态
4. **容器资源限制**：为Docker容器设置适当的内存和CPU限制
5. **数据隔离**：确保开发环境的数据操作不会影响生产数据
6. **自动化脚本**：创建脚本自动化常见操作，提高开发效率

## 结论

混合模式Docker开发环境结合了本地代码开发的灵活性和远程数据环境的真实性，特别适合微服务架构下的开发工作。通过Apollo配置中心的动态配置能力，可以轻松实现本地代码连接远程数据源，大大简化了开发环境的设置和维护工作。

这种模式使开发者能够专注于代码开发，而不必担心数据同步和环境配置问题，提高了开发效率和代码质量。