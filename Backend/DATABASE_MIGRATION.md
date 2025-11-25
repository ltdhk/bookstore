# 数据库迁移指南 (Database Migration Guide)

## 当前错误

如果您遇到以下错误：
```
java.sql.SQLSyntaxErrorException: Unknown column 'likes' in 'field list'
java.sql.SQLSyntaxErrorException: Unknown column 'completion_status' in 'field list'
```

这是因为数据库表结构与代码不匹配。请按照以下步骤更新数据库。

## 迁移步骤

### 方案一：完整重建（适用于开发环境，会删除所有数据）

1. 登录MySQL：
```bash
mysql -u root -p
```

2. 执行schema.sql重建所有表：
```bash
source /path/to/Backend/src/main/resources/db/schema.sql
```

### 方案二：增量迁移（推荐，保留现有数据）

按顺序执行以下迁移文件：

#### 1. 添加likes字段到books表
```bash
mysql -u root -p bookstore_db < Backend/src/main/resources/db/migration_add_likes.sql
```

或在MySQL命令行中：
```sql
USE bookstore_db;

ALTER TABLE `books`
ADD COLUMN IF NOT EXISTS `likes` bigint(20) DEFAULT 0 COMMENT 'Like Count' AFTER `views`;
```

#### 2. 创建tags和book_tags表
```bash
mysql -u root -p bookstore_db < Backend/src/main/resources/db/migration_add_tags.sql
```

或在MySQL命令行中执行 [migration_add_tags.sql](src/main/resources/db/migration_add_tags.sql) 的内容。

#### 3. 添加completion_status字段到books表
```bash
mysql -u root -p bookstore_db < Backend/src/main/resources/db/migration_add_completion_status.sql
```

或在MySQL命令行中：
```sql
USE bookstore_db;

ALTER TABLE `books`
ADD COLUMN `completion_status` varchar(20) DEFAULT 'ongoing' COMMENT 'Completion Status: ongoing, completed' AFTER `status`;
```

## 验证迁移

执行以下SQL验证表结构是否正确：

```sql
USE bookstore_db;

-- 检查books表结构
DESC books;

-- 检查tags表是否存在
DESC tags;

-- 检查book_tags表是否存在
DESC book_tags;

-- 查看tags数据
SELECT * FROM tags;
```

## 预期结果

### books表应该包含的字段：
- id
- title
- author
- cover_url
- description
- category_id
- status
- **completion_status** ← 新增 (ongoing/completed)
- views
- **likes** ← 新增
- rating
- language
- requires_membership
- is_recommended
- is_hot
- created_at
- updated_at
- deleted

### tags表应该包含10条默认数据：
- 5条中文标签（热门、新书、精选、完结、连载中）
- 5条英文标签（Hot、New、Featured、Completed、Ongoing）

## 常见问题

### Q: 如何只在Windows上执行SQL文件？
A: 在cmd或PowerShell中：
```cmd
mysql -u root -p bookstore_db < "C:\path\to\migration_add_likes.sql"
```

### Q: 如果已经手动创建了tags表但没有language字段怎么办？
A: 执行以下SQL添加language字段并更新唯一键：
```sql
USE bookstore_db;

-- 添加language字段
ALTER TABLE `tags`
ADD COLUMN `language` varchar(10) NOT NULL DEFAULT 'zh' COMMENT 'Language Code' AFTER `name`;

-- 删除旧的唯一键
ALTER TABLE `tags` DROP INDEX `uk_name`;

-- 添加新的唯一键
ALTER TABLE `tags` ADD UNIQUE KEY `uk_name_language` (`name`, `language`);

-- 为现有数据设置语言为中文
UPDATE `tags` SET `language` = 'zh' WHERE `language` IS NULL OR `language` = '';
```

### Q: 迁移后后端仍然报错？
A: 重启Spring Boot应用以重新加载数据库连接。

## Windows快速执行命令

在项目根目录打开PowerShell：

```powershell
# 导航到Backend目录
cd Backend\src\main\resources\db

# 执行likes字段迁移
mysql -u root -p bookstore_db -e "ALTER TABLE books ADD COLUMN IF NOT EXISTS likes bigint(20) DEFAULT 0 COMMENT 'Like Count' AFTER views;"

# 执行tags表迁移
Get-Content migration_add_tags.sql | mysql -u root -p bookstore_db

# 执行completion_status字段迁移
mysql -u root -p bookstore_db -e "ALTER TABLE books ADD COLUMN completion_status varchar(20) DEFAULT 'ongoing' COMMENT 'Completion Status: ongoing, completed' AFTER status;"
```
