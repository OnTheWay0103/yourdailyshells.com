# Elasticsearch 学习路径，从零基础到中高级

---

## Elasticsearch 系统学习教程：从入门到精通

### 第一阶段：初级入门 (目标：了解核心概念，能够进行基本的增删改查)

#### 1. 核心概念理解 (Mental Model)
首先，不要急于写代码。理解这些核心概念至关重要，它们是你学习 ES 的基石。

*   **Elasticsearch 是什么？**
    *   一个分布式的、开源的**搜索和分析引擎**。
    *   基于 **Apache Lucene** 构建，提供了隐藏 Lucene 复杂性的 RESTful API。
    *   常用于：应用程序搜索、日志处理与分析、实时数据监控等。

*   **核心术语对比 (vs. 传统数据库)**
    | 传统数据库 (MySQL) | Elasticsearch | 说明 |
    | :--- | :--- | :--- |
    | Database | **Index** | 索引是文档的集合。 |
    | Table | **Index** (类型概念在 7.x 后已逐渐废弃) | 在 7.x 之前，一个 Index 下可以有多个 Type，类似于表。现在默认只有一个 `_doc` type。**简单理解：一个 Index 即一个表**。 |
    | Row | **Document** | 文档是一条可被索引的数据基本单位，是 JSON 格式。 |
    | Column | **Field** | 文档中的字段，即 JSON 中的 key。 |
    | Schema | **Mapping** | 定义索引中的字段名称、数据类型（如 text, keyword, long）等元数据。 |
    | SQL | **Query DSL** | Elasticsearch 使用基于 JSON 的查询语言来进行检索。 |
    | `SELECT * FROM table` | `GET index/_search` | 搜索请求 |
    | `INSERT INTO ...` | `PUT index/_doc/1 { ... }` | 插入文档 |

*   **节点 (Node) 与集群 (Cluster)**
    *   **节点**：一个运行中的 Elasticsearch 实例。
    *   **集群**：由一个或多个拥有相同 `cluster.name` 的节点组成。它们协同工作，共享数据，提供高可用性和扩展性。

*   **分片 (Shard) 与副本 (Replica)**
    *   **分片**：索引可以被分割成多个部分，每个部分就是一个分片。它允许你**水平分割/扩展**你的数据量，提高性能。
    *   **副本**：是分片的拷贝。它提供**高可用性**，防止节点故障导致数据丢失，同时也能服务于搜索请求，提高搜索吞吐量。

#### 2. 环境搭建与初体验
1.  **安装 Elasticsearch 和 Kibana**
    *   **推荐使用 Docker**：这是最快、最干净的方式，避免环境冲突。
        ```bash
        # 创建网络
        docker network create elastic

        # 启动 Elasticsearch
        docker run --name es01 --net elastic -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -t docker.elastic.co/elasticsearch/elasticsearch:8.11.0

        # 启动 Kibana (Web 管理界面)
        docker run --name kibana --net elastic -p 5601:5601 docker.elastic.co/kibana/kibana:8.11.0
        ```
    *   访问 `http://localhost:9200` 查看 ES 是否启动成功。
    *   访问 `http://localhost:5601` 打开 Kibana 界面。

2.  **使用 Kibana Dev Tools 进行操作**
    *   Kibana 的 Dev Tools 提供了一个非常方便的界面来编写和发送 REST API 请求。

#### 3. 基础 CRUD 操作
在 Kibana Dev Tools 中尝试以下命令：

*   **创建索引**：
    ```json
    PUT /my-first-index
    ```
*   **插入文档 (指定 ID)**：
    ```json
    PUT /my-first-index/_doc/1
    {
      "title": "这是一篇关于 Elasticsearch 的文档",
      "content": "学习 Elasticsearch 真的很有趣！",
      "tags": ["技术", "搜索", "数据库"],
      "create_time": "2023-10-27"
    }
    ```
*   **插入文档 (不指定 ID，自动生成)**：
    ```json
    POST /my-first-index/_doc
    {
      "title": "另一篇文档"
    }
    ```
*   **查询文档**：
    ```json
    GET /my-first-index/_doc/1
    ```
*   **更新文档 (全量替换)**：
    ```json
    PUT /my-first-index/_doc/1
    {
      "title": "这是一篇被更新过的文档",
      "content": "新的内容来了！",
      "new_field": "新增的字段"
    }
    ```
*   **更新文档 (部分更新)**：
    ```json
    POST /my-first-index/_update/1
    {
      "doc": {
        "content": "只更新了内容部分"
      }
    }
    ```
*   **删除文档**：
    ```json
    DELETE /my-first-index/_doc/1
    ```
*   **删除索引**：
    ```json
    DELETE /my-first-index
    ```
*   **搜索文档 (最简单的查询)**：
    ```json
    GET /my-first-index/_search
    {
      "query": {
        "match_all": {} // 匹配所有文档
      }
    }
    ```

---

### 第二阶段：中级进阶 (目标：掌握搜索、聚合和映射管理)

#### 1. 深入 Query DSL (搜索)
Elasticsearch 的威力在于其强大的搜索能力。Query DSL 基于 JSON，主要分为两种类型：

*   **叶子查询 (Leaf Queries)**：在特定字段中查找特定值，如 `match`, `term`, `range`。
    *   `match`：**全文搜索**，会对查询文本进行分词。
        ```json
        GET /my-first-index/_search
        {
          "query": {
            "match": {
              "content": "学习 有趣" // 会分词为“学习”和“有趣”，包含任意词的文档都会被匹配
            }
          }
        }
        ```
    *   `term`：**精确值搜索**，不会对查询文本进行分词，直接去倒排索引中匹配确切的词条。
        ```json
        {
          "query": {
            "term": {
              "tags.keyword": "技术" // 精确匹配 tags 数组中值为“技术”的文档
            }
          }
        }
        ```
    *   `range`：范围查询。
        ```json
        {
          "query": {
            "range": {
              "create_time": {
                "gte": "2023-10-01",
                "lte": "2023-10-31"
              }
            }
          }
        }
        ```

*   **复合查询 (Compound Queries)**：可以组合其他叶子查询或复合查询，如 `bool`, `must_not`。
    *   `bool`：最常用的复合查询，可以组合多个查询条件。
        *   `must`：**必须满足**，贡献算分。
        *   `filter`：**必须满足**，但不贡献算分（性能更好，常用于过滤）。
        *   `should`：**应该满足**（满足条件会提高相关性得分）。
        *   `must_not`：**必须不满足**，不贡献算分。
    ```json
    GET /my-first-index/_search
    {
      "query": {
        "bool": {
          "must": [
            { "match": { "content": "学习" } }
          ],
          "filter": [
            { "term": { "tags.keyword": "技术" } },
            { "range": { "create_time": { "gte": "2023-10-01" } } }
          ],
          "must_not": [
            { "match": { "content": "困难" } }
          ]
        }
      }
    }
    ```

#### 2. 聚合分析 (Aggregations)
聚合提供了分组和提取统计信息的能力，类似于 SQL 中的 `GROUP BY` 和聚合函数。

*   **指标聚合 (Metric Aggregation)**：计算指标，如 `avg`, `sum`, `max`, `min`, `stats`。
    ```json
    GET /my-first-index/_search
    {
      "aggs": {
        "avg_score": { // 自定义聚合名称
          "avg": { // 求平均值的指标聚合
            "field": "score"
          }
        }
      }
    }
    ```

*   **桶聚合 (Bucket Aggregation)**：将文档分组到不同的桶中，如 `terms`, `date_histogram`。
    ```json
    GET /my-first-index/_search
    {
      "aggs": {
        "popular_tags": { // 按标签分组
          "terms": {
            "field": "tags.keyword", // 对 keyword 类型的字段进行分组
            "size": 10
          }
        },
        "create_time_histogram": { // 按时间分组（例如，按月）
          "date_histogram": {
            "field": "create_time",
            "calendar_interval": "month"
          }
        }
      }
    }
    ```

#### 3. 映射 (Mapping) 与数据类型
Mapping 类似于数据库的表结构定义，它非常重要，直接影响了数据的索引和搜索方式。

*   **核心数据类型**：
    *   `text`：**用于全文搜索**的字符串类型。会被分词器（Analyzer）拆分成词条。**不能被用于精确排序或聚合**（除非使用 `fielddata`，但不推荐）。
    *   `keyword`：**用于精确值**的字符串类型，如邮箱、标签、状态码。常用于过滤、排序和聚合。**不会被分词**。
    *   `date`：日期类型。
    *   `long`, `integer`, `short`, `byte`, `double`, `float`：数值类型。
    *   `boolean`：布尔类型。
    *   `object`, `nested`：用于处理 JSON 对象和数组。

*   **动态映射 vs. 显式映射**：
    *   **动态映射**：当你插入一个新文档时，如果索引不存在，ES 会自动创建索引并根据文档字段的值来**猜测**其数据类型。这很方便，但有时会猜错（例如，将 `"123"` 映射为 `text` 而非 `integer`）。
    *   **显式映射**：**最佳实践是预先定义好映射**，确保数据类型的正确性。
        ```json
        PUT /my-blog
        {
          "mappings": {
            "properties": {
              "title": {
                "type": "text",       // 全文搜索
                "fields": {           // 多字段特性
                  "keyword": {        // 定义一个子字段，名为 keyword，类型为 keyword
                    "type": "keyword" // 用于精确匹配、排序和聚合
                  }
                }
              },
              "content": { "type": "text" },
              "tags": { "type": "keyword" }, // 标签数组，每个元素都是 keyword
              "create_time": { "type": "date" },
              "views": { "type": "integer" }
            }
          }
        }
        ```
        这样，你可以对 `title` 进行全文搜索，同时对 `title.keyword` 进行排序和聚合。

---

### 第三阶段：高级掌握 (目标：理解集群管理、性能调优和复杂场景)

#### 1. 集群管理与监控
*   **Cat API**：用于查看集群状态的简洁 API。
    *   `GET /_cat/health?v`：查看集群健康状态 (green, yellow, red)。
    *   `GET /_cat/nodes?v`：查看节点信息。
    *   `GET /_cat/indices?v`：查看所有索引信息（大小、文档数、健康状态）。

*   **集群扩容**：通过增加节点，ES 会自动将分片分配到新节点上，实现水平扩展。

*   **使用 Kibana 监控**：Kibana 提供了强大的可视化监控工具（Stack Monitoring），可以监控集群 CPU、内存、磁盘、索引速率、查询延迟等关键指标。

#### 2. 性能调优
*   **刷新间隔 (Refresh Interval)**：默认 1s。索引的文档需要经过“刷新”才能被搜索到。增加间隔可以降低 I/O 压力，提高索引吞吐量（牺牲实时性）。
    ```json
    PUT /my-index/_settings
    {
      "index.refresh_interval": "30s"
    }
    ```
*   **分片策略**：
    *   **分片大小**：推荐单个分片大小在 **20GB - 40GB** 之间。
    *   **分片数量**：分片数过多会导致管理开销增大；过少则无法充分利用集群资源。**在创建索引时就要规划好，因为后期修改非常麻烦**。
*   **使用 `filter` 上下文**：`filter` 查询会被缓存，并且不计算得分，性能远优于 `must` 或 `should`。所有不需要相关性算分的条件（如时间范围、状态过滤）都应放在 `filter` 中。
*   **避免深度分页**：`from + size` 方式在深度分页时（如 `from=10000`）性能极差。推荐使用 `search_after` 参数进行滚动查询。

#### 3. 处理关联关系
ES 不是关系型数据库，处理关联关系是其弱项，但有几种模式：
*   **Denormalization (反规范化)**：**首选方案**。将关联数据冗余到主文档中。用空间换时间，提高查询速度。
*   **Nested Data Type**：允许在文档中存储对象数组，并保持数组中对象的独立性（可以独立查询）。但查询性能较低。
*   **Parent/Join Data Type**：模拟父子关系。**非常影响性能，除非万不得已，否则不推荐使用**。

#### 4. 实战项目建议
将所学知识应用于一个完整的项目：
1.  **日志分析系统 (ELK Stack)**：使用 Filebeat 收集 Nginx/应用日志，写入 ES，用 Kibana 做可视化分析。这是最经典的用例。
2.  **商品搜索平台**：模拟电商网站，为商品数据创建索引，实现：
    *   关键字搜索、拼写纠错
    *   按品牌、分类、价格区间进行过滤和聚合
    *   相关商品推荐

### 学习资源
*   **官方文档**：https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html - **永远是最好的教程**，内容最准确、最全面。
*   **Elastic 中文社区**：https://elasticsearch.cn/ - 有很多高质量的讨论和分享。

---

这个路径涵盖了 Elasticsearch 的核心知识体系。记住，**理论结合实践**是关键。多动手在 Kibana Dev Tools 里敲命令，多尝试构建不同的查询和聚合，遇到问题先查阅官方文档。祝你学习顺利！