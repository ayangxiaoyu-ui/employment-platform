# 大学生就业服务平台 Mermaid 图集

> 说明：以下图均可直接复制到支持 Mermaid 的编辑器中导出图片。  
> 若你的渲染器不支持 `erDiagram` 的中文字段名，可把中文改为英文后再渲染。

---

## 1. 系统功能结构图

```mermaid
graph TD
    A[大学生就业服务平台]

    A --> B[学生端]
    A --> C[企业端]
    A --> D[管理员端]
    A --> E[平台公共能力]

    B --> B1[注册登录]
    B --> B2[岗位浏览与筛选]
    B --> B3[岗位收藏与浏览记录]
    B --> B4[在线简历管理]
    B --> B5[附件简历上传]
    B --> B6[职位投递与状态跟踪]
    B --> B7[消息沟通]
    B --> B8[就业指导浏览]

    C --> C1[企业资料维护]
    C --> C2[岗位发布与管理]
    C --> C3[简历收件箱]
    C --> C4[学生人才浏览]
    C --> C5[投递状态处理]
    C --> C6[消息沟通]
    C --> C7[就业指导发布管理]

    D --> D1[管理员登录]
    D --> D2[运营看板]
    D --> D3[新闻管理]
    D --> D4[就业指导管理]

    E --> E1[JWT鉴权]
    E --> E2[角色权限控制]
    E --> E3[文件上传与静态资源映射]
    E --> E4[统一返回体]
```

---

## 1.1 系统总体架构图

> 前后端分离 + 典型三层（接口 / 业务 / 持久）+ 数据与文件存储，适合论文「系统总体设计 / 架构设计」小节。

### 1.1.1 分层总体架构（推荐）

```mermaid
flowchart TB
    subgraph Client[客户端]
        U[浏览器]
    end

    subgraph Presentation[表现层 · 前端]
        FE[Vue3 + TypeScript + Vue Router]
    end

    subgraph Server[服务端 · Spring Boot]
        direction TB
        C[Controller 控制层 REST API]
        S[Service 业务层]
        M[Mapper 持久层 MyBatis-Plus]
        C --> S
        S --> M
        I[JWT 拦截器 / 鉴权]
        I -.-> C
    end

    subgraph Storage[存储与资源]
        DB[(MySQL 数据库)]
        FS[(本地文件 uploads\n头像·Logo·简历·封面)]
    end

    U -->|HTTP| FE
    FE -->|JSON + Bearer Token| C
    U -->|静态资源 URL| C
    M --> DB
    S --> FS
    C -->|ResourceHandler\n静态映射| FS
```

### 1.1.2 简化总体架构（版面紧凑）

```mermaid
graph LR
    A[浏览器] --> B[Vue3 前端]
    B -->|REST + JWT| C[Spring Boot 后端]
    C --> D[(MySQL)]
    C --> E[(本地文件存储)]
```

### 1.1.3 请求交互示意（可选）

```mermaid
sequenceDiagram
    participant B as 浏览器
    participant V as Vue 前端
    participant S as Spring Boot
    participant D as MySQL

    B->>V: 访问页面
    V->>S: API 请求 Authorization Bearer
    S->>S: JWT 校验 / 角色判断
    S->>D: SQL 读写
    D-->>S: 结果集
    S-->>V: JSON 统一返回体
    V-->>B: 渲染界面
```

---

## 2. 系统整体用例图

```mermaid
flowchart LR
    Student[学生]
    Company[企业]
    Admin[管理员]

    subgraph System[大学生就业服务平台]
      UC1((注册/登录))
      UC2((管理个人资料))
      UC3((浏览/筛选岗位))
      UC4((收藏岗位))
      UC5((管理简历))
      UC6((投递职位))
      UC7((查看投递状态))
      UC8((消息沟通))
      UC9((浏览就业指导))

      UC10((维护企业资料))
      UC11((发布/管理岗位))
      UC12((查看简历收件箱))
      UC13((浏览学生人才))
      UC14((处理投递状态))
      UC15((发布就业指导))

      UC16((管理新闻))
      UC17((管理就业指导))
      UC18((查看平台看板))
    end

    Student --> UC1
    Student --> UC2
    Student --> UC3
    Student --> UC4
    Student --> UC5
    Student --> UC6
    Student --> UC7
    Student --> UC8
    Student --> UC9

    Company --> UC1
    Company --> UC10
    Company --> UC11
    Company --> UC12
    Company --> UC13
    Company --> UC14
    Company --> UC8
    Company --> UC15

    Admin --> UC1
    Admin --> UC16
    Admin --> UC17
    Admin --> UC18
```

---

## 2.1 学生角色用例图

> 仅展示学生（STUDENT）与系统之间的用例关系，适合论文「学生端用例分析」小节。

```mermaid
flowchart TB
    Actor[学生]

    subgraph Platform[大学生就业服务平台 · 学生端]
        direction TB

        subgraph Account[账号与资料]
            UC1((注册账号))
            UC2((登录系统))
            UC3((维护学生个人资料))
        end

        subgraph Job[岗位与求职]
            UC4((浏览企业列表))
            UC5((查看企业详情))
            UC6((浏览/筛选岗位))
            UC7((查看岗位详情))
            UC8((收藏岗位))
            UC9((查看浏览记录))
        end

        subgraph Resume[简历]
            UC10((编辑在线简历))
            UC11((上传附件简历))
            UC12((管理简历列表))
        end

        subgraph Apply[投递与进度]
            UC13((投递职位))
            UC14((查看投递记录与状态))
        end

        subgraph Comm[沟通与内容]
            UC15((与企业消息沟通))
            UC16((浏览就业指导))
            UC17((浏览新闻资讯))
        end
    end

    Actor --> UC1
    Actor --> UC2
    Actor --> UC3
    Actor --> UC4
    Actor --> UC5
    Actor --> UC6
    Actor --> UC7
    Actor --> UC8
    Actor --> UC9
    Actor --> UC10
    Actor --> UC11
    Actor --> UC12
    Actor --> UC13
    Actor --> UC14
    Actor --> UC15
    Actor --> UC16
    Actor --> UC17
```

### 2.1.1 学生用例图（扁平版 · 导出更紧凑）

若渲染器对子图支持不好，可用下面扁平版：

```mermaid
flowchart LR
    S[学生]

    subgraph Sys[系统]
        A1((注册))
        A2((登录))
        A3((个人资料))
        A4((浏览企业))
        A5((浏览筛选岗位))
        A6((岗位详情))
        A7((收藏岗位))
        A8((浏览记录))
        A9((在线简历))
        A10((附件简历))
        A11((投递职位))
        A12((投递状态))
        A13((消息))
        A14((就业指导))
        A15((新闻))
    end

    S --> A1
    S --> A2
    S --> A3
    S --> A4
    S --> A5
    S --> A6
    S --> A7
    S --> A8
    S --> A9
    S --> A10
    S --> A11
    S --> A12
    S --> A13
    S --> A14
    S --> A15
```

---

## 2.2 企业角色用例图

> 仅展示企业（COMPANY）与系统之间的用例关系，适合论文「企业端用例分析」小节。

```mermaid
flowchart TB
    Actor[企业用户]

    subgraph Platform[大学生就业服务平台 · 企业端]
        direction TB

        subgraph Account[账号与企业资料]
            UC1((注册企业账号))
            UC2((登录系统))
            UC3((维护企业资料))
        end

        subgraph Job[岗位管理]
            UC4((发布岗位))
            UC5((管理本企业岗位列表))
            UC6((查看岗位详情))
        end

        subgraph Talent[人才与简历]
            UC7((浏览学生人才库))
            UC8((查看学生详情))
            UC9((查看简历收件箱))
            UC10((查看候选人简历详情))
        end

        subgraph Apply[投递处理]
            UC11((标记投递已查看))
            UC12((更新投递状态))
        end

        subgraph Board[数据看板]
            UC13((查看企业投递统计看板))
        end

        subgraph Comm[沟通与内容]
            UC14((与学生消息沟通))
            UC15((发布/管理企业就业指导))
        end
    end

    Actor --> UC1
    Actor --> UC2
    Actor --> UC3
    Actor --> UC4
    Actor --> UC5
    Actor --> UC6
    Actor --> UC7
    Actor --> UC8
    Actor --> UC9
    Actor --> UC10
    Actor --> UC11
    Actor --> UC12
    Actor --> UC13
    Actor --> UC14
    Actor --> UC15
```

### 2.2.1 企业用例图（扁平版 · 导出更紧凑）

若渲染器对子图支持不好，可用下面扁平版：

```mermaid
flowchart LR
    C[企业用户]

    subgraph Sys[系统]
        B1((注册))
        B2((登录))
        B3((企业资料))
        B4((发布岗位))
        B5((管理岗位))
        B6((浏览人才))
        B7((学生详情))
        B8((简历收件箱))
        B9((简历详情))
        B10((标记已读))
        B11((更新投递状态))
        B12((企业看板))
        B13((消息))
        B14((就业指导))
    end

    C --> B1
    C --> B2
    C --> B3
    C --> B4
    C --> B5
    C --> B6
    C --> B7
    C --> B8
    C --> B9
    C --> B10
    C --> B11
    C --> B12
    C --> B13
    C --> B14
```

---

## 2.3 管理员角色用例图

> 仅展示管理员（ADMIN）与系统之间的用例关系，适合论文「管理端用例分析」小节。

```mermaid
flowchart TB
    Actor[管理员]

    subgraph Platform[大学生就业服务平台 · 管理端]
        direction TB

        subgraph Account[账号]
            UC1((登录系统))
        end

        subgraph Board[运营与统计]
            UC2((查看管理端数据看板))
        end

        subgraph News[新闻资讯]
            UC3((管理新闻列表))
            UC4((新增新闻))
            UC5((编辑新闻))
            UC6((删除新闻))
        end

        subgraph Guide[就业指导 · 平台级]
            UC7((查看全部就业指导))
            UC8((发布平台就业指导))
            UC9((编辑任意就业指导))
            UC10((删除任意就业指导))
        end
    end

    Actor --> UC1
    Actor --> UC2
    Actor --> UC3
    Actor --> UC4
    Actor --> UC5
    Actor --> UC6
    Actor --> UC7
    Actor --> UC8
    Actor --> UC9
    Actor --> UC10
```

### 2.3.1 管理员用例图（扁平版 · 导出更紧凑）

若渲染器对子图支持不好，可用下面扁平版：

```mermaid
flowchart LR
    A[管理员]

    subgraph Sys[系统]
        M1((登录))
        M2((数据看板))
        M3((新闻列表))
        M4((新增新闻))
        M5((编辑新闻))
        M6((删除新闻))
        M7((指导列表))
        M8((发布指导))
        M9((编辑指导))
        M10((删除指导))
    end

    A --> M1
    A --> M2
    A --> M3
    A --> M4
    A --> M5
    A --> M6
    A --> M7
    A --> M8
    A --> M9
    A --> M10
```

---

## 3. 各核心功能流程图

### 3.1 用户注册/登录流程

```mermaid
flowchart TD
    A[用户进入登录/注册页] --> B{是否已有账号}
    B -- 否 --> C[填写注册信息]
    C --> D[提交注册]
    D --> E{注册是否成功}
    E -- 否 --> C1[提示错误并重试]
    E -- 是 --> F[返回登录页]
    B -- 是 --> G[填写账号密码]
    F --> G
    G --> H[提交登录]
    H --> I{认证成功?}
    I -- 否 --> J[提示账号或密码错误]
    I -- 是 --> K[签发JWT Token]
    K --> L[按角色跳转首页]
```

### 3.2 学生岗位浏览与筛选流程

```mermaid
flowchart TD
    A[学生进入岗位列表] --> B[加载最新/热门岗位]
    B --> C{是否输入筛选条件}
    C -- 是 --> D[按关键词/分类筛选]
    C -- 否 --> E[展示默认列表]
    D --> F[展示筛选结果]
    E --> G[点击岗位详情]
    F --> G
    G --> H[记录浏览历史]
    H --> I[显示岗位详情与企业信息]
```

### 3.3 简历管理流程（在线 + 附件）

```mermaid
flowchart TD
    A[学生进入简历管理] --> B{选择简历类型}
    B -- 在线简历 --> C[编辑内容并保存]
    C --> D{已有在线简历?}
    D -- 是 --> E[更新在线简历]
    D -- 否 --> F[创建在线简历]
    E --> G[返回保存成功]
    F --> G

    B -- 附件简历 --> H[选择PDF文件上传]
    H --> I{文件校验通过?}
    I -- 否 --> J[提示上传失败]
    I -- 是 --> K{是否同名简历}
    K -- 是 --> L[提示是否覆盖]
    L --> M[覆盖或取消]
    K -- 否 --> N[保存附件简历记录]
    M --> O[返回结果]
    N --> O
```

### 3.4 职位投递流程

```mermaid
flowchart TD
    A[学生查看岗位详情] --> B[点击投递]
    B --> C[选择简历]
    C --> D[提交投递请求]
    D --> E{是否重复投递}
    E -- 是 --> F[返回已投递提示]
    E -- 否 --> G[写入投递记录 status=待查看]
    G --> H[投递成功]
    H --> I[学生端可查看投递状态]
```

### 3.5 企业收件箱处理流程

```mermaid
flowchart TD
    A[企业登录后台] --> B[进入简历收件箱]
    B --> C[加载企业岗位投递记录]
    C --> D[聚合岗位/学生/简历信息]
    D --> E[查看候选人详情]
    E --> F{处理结果}
    F -- 已查看 --> G[状态更新为已查看]
    F -- 面试邀请 --> H[状态更新为面试邀请]
    F -- 不合适 --> I[状态更新为不合适]
    F -- 录用 --> J[状态更新为已录用]
    G --> K[返回收件箱列表]
    H --> K
    I --> K
    J --> K
```

### 3.6 消息沟通流程（学生-企业）

```mermaid
flowchart TD
    A[用户进入消息中心] --> B[加载会话列表]
    B --> C[选择会话对象]
    C --> D[加载历史消息]
    D --> E[输入消息内容]
    E --> F[发送消息]
    F --> G[保存消息 isRead=0]
    G --> H[接收方查看会话]
    H --> I[标记消息已读]
```

### 3.7 就业指导内容流程（企业/管理员）

```mermaid
flowchart TD
    A[发布者进入指导管理] --> B{角色判断}
    B -- 企业 --> C[发布企业指导文章]
    B -- 管理员 --> D[发布平台指导文章]
    C --> E[保存文章并展示列表]
    D --> E
    E --> F[用户浏览指导列表]
    F --> G[查看指导详情]
    G --> H[浏览量+1]
```

### 3.8 管理员内容管理流程

```mermaid
flowchart TD
    A[管理员登录] --> B[进入管理后台]
    B --> C{选择模块}
    C -- 新闻管理 --> D[新增/编辑/删除新闻]
    C -- 指导管理 --> E[新增/编辑/删除指导]
    C -- 看板 --> F[查看统计数据]
    D --> G[保存并返回列表]
    E --> G
    F --> H[结束]
    G --> H
```

---

## 4.0 系统 ER 图（全库实体关系 · 推荐导出）

> 覆盖 `employment_platform` 库中主要业务表及关联。`message.sender_id` / `receiver_id` 在脚本中均为 **`sys_user.id`**（学生/企业/管理员账号均可作为收发方），与 `student`/`company` 表无直接外键。

```mermaid
erDiagram
    SYS_USER ||--o| STUDENT : "1对0/1"
    SYS_USER ||--o| COMPANY : "1对0/1"
    SYS_USER ||--o{ NEWS : "author_id"
    SYS_USER ||--o{ GUIDE : "user_id可空"

    SYS_USER ||--o{ MESSAGE : "sender_id"
    SYS_USER ||--o{ MESSAGE : "receiver_id"

    COMPANY ||--o{ JOB : "发布"
    CATEGORY ||--o{ JOB : "分类"

    STUDENT ||--o{ RESUME : "拥有"
    STUDENT ||--o{ APPLICATION : "投递"
    STUDENT ||--o{ FAVORITE : "收藏"
    STUDENT ||--o{ BROWSING_HISTORY : "浏览"

    JOB ||--o{ APPLICATION : "被投递"
    RESUME ||--o{ APPLICATION : "使用简历"

    JOB ||--o{ FAVORITE : "被收藏"
    JOB ||--o{ BROWSING_HISTORY : "被浏览"

    SYS_USER {
        bigint id PK
        varchar username
        varchar password
        varchar role
        datetime create_time
    }
    STUDENT {
        bigint id PK
        bigint user_id FK
        varchar name
        varchar university
        varchar major
    }
    COMPANY {
        bigint id PK
        bigint user_id FK
        varchar name
        int status
    }
    CATEGORY {
        bigint id PK
        varchar name
        int type
        bigint parent_id
    }
    JOB {
        bigint id PK
        bigint company_id FK
        bigint category_id FK
        varchar title
        int status
    }
    RESUME {
        bigint id PK
        bigint student_id FK
        int type
        varchar file_url
    }
    APPLICATION {
        bigint id PK
        bigint job_id FK
        bigint student_id FK
        bigint resume_id FK
        int status
    }
    FAVORITE {
        bigint id PK
        bigint student_id FK
        bigint job_id FK
    }
    BROWSING_HISTORY {
        bigint id PK
        bigint student_id FK
        bigint job_id FK
    }
    MESSAGE {
        bigint id PK
        bigint sender_id FK
        bigint receiver_id FK
        int is_read
    }
    GUIDE {
        bigint id PK
        bigint user_id FK
        varchar title
        int view_count
    }
    NEWS {
        bigint id PK
        bigint author_id FK
        varchar title
        int view_count
    }
```

### 4.0.1 系统 ER 图（仅关系线 · 字段最少 · 大图友好）

```mermaid
erDiagram
    SYS_USER ||--o| STUDENT : maps
    SYS_USER ||--o| COMPANY : maps
    SYS_USER ||--o{ NEWS : writes
    SYS_USER ||--o{ GUIDE : writes
    SYS_USER ||--o{ MESSAGE : sends
    SYS_USER ||--o{ MESSAGE : receives

    COMPANY ||--o{ JOB : publishes
    CATEGORY ||--o{ JOB : classifies

    STUDENT ||--o{ RESUME : owns
    STUDENT ||--o{ APPLICATION : submits
    JOB ||--o{ APPLICATION : receives
    RESUME ||--o{ APPLICATION : used_by

    STUDENT ||--o{ FAVORITE : saves
    JOB ||--o{ FAVORITE : bookmarked

    STUDENT ||--o{ BROWSING_HISTORY : tracks
    JOB ||--o{ BROWSING_HISTORY : viewed
```

---

## 4. 数据库 ER 图（核心业务表）

```mermaid
erDiagram
    SYS_USER ||--o| STUDENT : "1对0/1"
    SYS_USER ||--o| COMPANY : "1对0/1"
    SYS_USER ||--o{ NEWS : "发布新闻"
    COMPANY ||--o{ JOB : "发布"
    STUDENT ||--o{ RESUME : "拥有"
    STUDENT ||--o{ APPLICATION : "投递"
    JOB ||--o{ APPLICATION : "被投递"
    RESUME ||--o{ APPLICATION : "用于投递"
    STUDENT ||--o{ FAVORITE : "收藏"
    JOB ||--o{ FAVORITE : "被收藏"
    STUDENT ||--o{ BROWSING_HISTORY : "浏览"
    JOB ||--o{ BROWSING_HISTORY : "被浏览"
    SYS_USER ||--o{ MESSAGE : "sender_id"
    SYS_USER ||--o{ MESSAGE : "receiver_id"
    SYS_USER ||--o{ GUIDE : "发布(可空)"
    CATEGORY ||--o{ JOB : "岗位分类"

    SYS_USER {
        bigint id PK
        varchar username
        varchar password
        varchar role
        datetime create_time
    }
    STUDENT {
        bigint id PK
        bigint user_id FK
        varchar name
        varchar gender
        varchar phone
        varchar email
        varchar university
        varchar major
    }
    COMPANY {
        bigint id PK
        bigint user_id FK
        varchar name
        varchar industry
        varchar scale
        varchar contact_person
        varchar contact_phone
        int status
    }
    CATEGORY {
        bigint id PK
        varchar name
        int type
        bigint parent_id
    }
    JOB {
        bigint id PK
        bigint company_id FK
        bigint category_id FK
        varchar title
        varchar location
        decimal salary_min
        decimal salary_max
        int status
        datetime create_time
    }
    RESUME {
        bigint id PK
        bigint student_id FK
        int type
        varchar title
        text content
        varchar file_url
        int is_public
        datetime update_time
    }
    APPLICATION {
        bigint id PK
        bigint job_id FK
        bigint student_id FK
        bigint resume_id FK
        int status
        datetime create_time
    }
    FAVORITE {
        bigint id PK
        bigint student_id FK
        bigint job_id FK
        datetime create_time
    }
    BROWSING_HISTORY {
        bigint id PK
        bigint student_id FK
        bigint job_id FK
        int count
        datetime update_time
    }
    MESSAGE {
        bigint id PK
        bigint sender_id
        bigint receiver_id
        text content
        int is_read
        datetime create_time
    }
    GUIDE {
        bigint id PK
        bigint user_id FK
        varchar title
        text content
        int view_count
        datetime create_time
    }
    NEWS {
        bigint id PK
        varchar title
        longtext content
        bigint author_id FK
        int view_count
        datetime create_time
    }
```

---

## 5. 系统整体 ER 图（分域视角）

```mermaid
erDiagram
    %% 账号域
    SYS_USER ||--o| STUDENT : "映射"
    SYS_USER ||--o| COMPANY : "映射"

    %% 招聘域
    COMPANY ||--o{ JOB : "管理"
    CATEGORY ||--o{ JOB : "归类"
    STUDENT ||--o{ RESUME : "管理"
    STUDENT ||--o{ APPLICATION : "发起"
    JOB ||--o{ APPLICATION : "接收"
    RESUME ||--o{ APPLICATION : "关联"

    %% 行为域
    STUDENT ||--o{ FAVORITE : "收藏行为"
    JOB ||--o{ FAVORITE : "收藏对象"
    STUDENT ||--o{ BROWSING_HISTORY : "浏览行为"
    JOB ||--o{ BROWSING_HISTORY : "浏览对象"

    %% 沟通与内容域（消息账号级，非学生/企业业务主键）
    SYS_USER ||--o{ MESSAGE : "发送"
    SYS_USER ||--o{ MESSAGE : "接收"
    SYS_USER ||--o{ GUIDE : "发布内容"
    SYS_USER ||--o{ NEWS : "新闻公告"
```

---

## 6. 实体关系 ER 图（逻辑模型补充 · 基数与角色）

> 与 `employment_platform.sql` 一致；便于在论文「概念结构设计 / 逻辑结构设计」中说明 **1:1、1:N、参与角色**。若渲染器对同一实体连两条线有兼容问题，可改用下一小节的「单向箭头」版。

### 6.1 全局实体关系（推荐导出）

```mermaid
erDiagram
    SYS_USER ||--o| STUDENT : "注册 1:0..1"
    SYS_USER ||--o| COMPANY : "注册 1:0..1"
    SYS_USER ||--o{ MESSAGE : "发件 sender_id 1:N"
    SYS_USER ||--o{ MESSAGE : "收件 receiver_id 1:N"
    SYS_USER ||--o{ NEWS : "author_id 1:N"
    SYS_USER ||--o{ GUIDE : "user_id 0..1:N"

    COMPANY ||--o{ JOB : "发布 1:N"
    CATEGORY ||--o{ JOB : "归类 0..1:N"
    STUDENT ||--o{ RESUME : "拥有 1:N"
    STUDENT ||--o{ APPLICATION : "投递 1:N"
    JOB ||--o{ APPLICATION : "收到投递 1:N"
    RESUME ||--o{ APPLICATION : "被选用 1:N"
    STUDENT ||--o{ FAVORITE : "收藏 1:N"
    JOB ||--o{ FAVORITE : "被收藏 1:N"
    STUDENT ||--o{ BROWSING_HISTORY : "浏览 1:N"
    JOB ||--o{ BROWSING_HISTORY : "被浏览 1:N"
```

### 6.2 实体关系（自顶向下 · 账号—招聘—行为）

```mermaid
flowchart TB
    subgraph Account[账号子模型]
        U[(sys_user)]
        S[(student)]
        C[(company)]
        U -->|user_id 1:1| S
        U -->|user_id 1:1| C
    end

    subgraph Recruit[招聘子模型]
        Cat[(category)]
        J[(job)]
        R[(resume)]
        Ap[(application)]
        C -->|1:N| J
        Cat -->|1:N| J
        S -->|1:N| R
        S -->|1:N| Ap
        J -->|1:N| Ap
        R -->|1:N| Ap
    end

    subgraph Behavior[行为子模型]
        F[(favorite)]
        BH[(browsing_history)]
        S -->|1:N| F
        J -->|1:N| F
        S -->|1:N| BH
        J -->|1:N| BH
    end

    subgraph Comm[消息与内容]
        M[(message)]
        G[(guide)]
        N[(news)]
        U -->|sender_id / receiver_id| M
        U -->|author_id| N
        U -.->|user_id 可空| G
    end
```

---

## 7. 后端 UML 类图（`com.example`）

> 对应 Spring Boot 工程 `springboot/src/main/java/com/example`。实体类与表字段一致；控制层仅列出公开 REST 接口类。

### 7.1 持久化实体类关联图（entity 包）

> 表达 **ORM 实体之间的逻辑关联**（非全部外键在库中声明，但字段含义与 ER 一致）。

```mermaid
classDiagram
    direction TB
    class SysUser {
        +Long id
        +String username
        +String password
        +String role
        +Integer status
    }
    class Student {
        +Long id
        +Long userId
        +String name
        +String university
        +String major
    }
    class Company {
        +Long id
        +Long userId
        +String name
        +Integer status
    }
    class Category {
        +Long id
        +String name
        +Integer type
        +Long parentId
    }
    class Job {
        +Long id
        +Long companyId
        +Long categoryId
        +String title
        +Integer status
    }
    class Resume {
        +Long id
        +Long studentId
        +Integer type
        +String content
        +String fileUrl
    }
    class Application {
        +Long id
        +Long jobId
        +Long studentId
        +Long resumeId
        +Integer status
    }
    class Favorite {
        +Long id
        +Long studentId
        +Long jobId
    }
    class BrowsingHistory {
        +Long id
        +Long studentId
        +Long jobId
        +Integer count
    }
    class Message {
        +Long id
        +Long senderId
        +Long receiverId
        +String content
        +Integer type
        +Integer isRead
    }
    class Guide {
        +Long id
        +Long userId
        +String title
        +String content
    }
    class News {
        +Long id
        +String title
        +String content
        +Long authorId
    }

    Student "n" --> "1" SysUser : userId
    Company "n" --> "1" SysUser : userId
    Job "n" --> "1" Company : companyId
    Job "n" --> "0..1" Category : categoryId
    Resume "n" --> "1" Student : studentId
    Application "n" --> "1" Job : jobId
    Application "n" --> "1" Student : studentId
    Application "n" --> "1" Resume : resumeId
    Favorite "n" --> "1" Student : studentId
    Favorite "n" --> "1" Job : jobId
    BrowsingHistory "n" --> "1" Student : studentId
    BrowsingHistory "n" --> "1" Job : jobId
    Message "n" --> "1" SysUser : senderId
    Message "n" --> "1" SysUser : receiverId
    News "n" --> "0..1" SysUser : authorId
    Guide "n" --> "0..1" SysUser : userId
```

### 7.2 典型三层类图（以职位与投递为例）

> **纵向切片**：表现层 → 业务接口与实现 → 持久层 Mapper → 实体。

```mermaid
classDiagram
    direction TB
    class JobController {
        +getJobList()
        +getJobDetail()
        +saveJob()
    }
    class ApplicationController {
        +apply()
        +listMine()
        +companyInbox()
    }
    class JobService {
        <<interface>>
        +pageJobs()
        +getById()
    }
    class JobServiceImpl {
        -JobMapper jobMapper
    }
    class ApplicationService {
        <<interface>>
        +submit()
        +updateStatus()
    }
    class ApplicationServiceImpl {
        -ApplicationMapper applicationMapper
    }
    class JobMapper {
        <<interface>>
    }
    class ApplicationMapper {
        <<interface>>
    }
    class Job
    class Application

    JobController ..> JobService :依赖
    ApplicationController ..> ApplicationService :依赖
    JobServiceImpl ..|> JobService
    ApplicationServiceImpl ..|> ApplicationService
    JobServiceImpl --> JobMapper
    ApplicationServiceImpl --> ApplicationMapper
    JobMapper ..> Job : 映射
    ApplicationMapper ..> Application : 映射
```

### 7.3 控制层与业务层依赖总览

> 一张图概括 **Controller → Service** 依赖（论文「系统类设计 / 包结构」可用）。

```mermaid
classDiagram
    direction LR
    class AuthController
    class UserController
    class StudentController
    class CompanyController
    class JobController
    class ApplicationController
    class ResumeController
    class FavoriteController
    class BrowsingHistoryController
    class MessageController
    class CategoryController
    class GuideController
    class NewsController
    class AdminDashboardController
    class FileController

    class UserService
    class SysUserService
    class StudentService
    class CompanyService
    class JobService
    class ApplicationService
    class ResumeService
    class FavoriteService
    class BrowsingHistoryService
    class MessageService
    class CategoryService
    class GuideService
    class NewsService

    AuthController ..> UserService
    UserController ..> UserService
    StudentController ..> StudentService
    CompanyController ..> CompanyService
    JobController ..> JobService
    ApplicationController ..> ApplicationService
    ResumeController ..> ResumeService
    FavoriteController ..> FavoriteService
    BrowsingHistoryController ..> BrowsingHistoryService
    MessageController ..> MessageService
    CategoryController ..> CategoryService
    GuideController ..> GuideService
    NewsController ..> NewsService
    AdminDashboardController ..> SysUserService
    AdminDashboardController ..> StudentService
    AdminDashboardController ..> CompanyService
    AdminDashboardController ..> JobService
    AdminDashboardController ..> ApplicationService
    AdminDashboardController ..> NewsService
    AdminDashboardController ..> GuideService
    AdminDashboardController ..> MessageService
    AdminDashboardController ..> ResumeService
```

---

## 8. 可选补充：系统部署架构图

```mermaid
graph LR
    U[浏览器]
    V[Vue3 前端]
    S[Spring Boot 后端]
    DB[(MySQL)]
    FS[(本地文件存储 uploads)]

    U --> V
    V -->|HTTP/JSON| S
    S --> DB
    S --> FS
    FS -->|静态资源映射| U
```

