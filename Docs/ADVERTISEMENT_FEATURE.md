# 广告功能使用指南

## 功能概述

APP首页顶部广告轮播功能已完成，可以从数据库中动态获取广告数据并展示。支持三种广告类型：
- **书籍跳转**：点击广告跳转到指定书籍详情页
- **URL跳转**：点击广告打开外部链接
- **无跳转**：仅展示图片，点击无操作

## 技术架构

### 后端（Backend）

#### 1. 数据库表结构
位置：`Backend/src/main/resources/db/schema.sql`

```sql
CREATE TABLE `advertisements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL COMMENT 'Advertisement Title',
  `image_url` varchar(255) NOT NULL COMMENT 'Advertisement Image URL',
  `target_type` varchar(20) NOT NULL DEFAULT 'book' COMMENT 'Target Type: book, url, none',
  `target_id` bigint(20) DEFAULT NULL COMMENT 'Target Book ID (if type is book)',
  `target_url` varchar(255) DEFAULT NULL COMMENT 'Target URL (if type is url)',
  `position` varchar(50) DEFAULT 'home_banner' COMMENT 'Position: home_banner, home_popup, etc.',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Sort Order (smaller number shows first)',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Is Active: 0-No, 1-Yes',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
```

#### 2. API接口

**管理端接口**（Admin）
- 位置：`Backend/src/main/java/com/bookstore/controller/admin/AdvertisementController.java`
- 基础路径：`/api/admin/advertisements`
- 功能：完整的CRUD操作（创建、读取、更新、删除广告）

**客户端接口**（Client）
- 位置：`Backend/src/main/java/com/bookstore/controller/AdvertisementController.java`
- 路径：`GET /api/advertisements`
- 参数：
  - `position`（可选）：位置过滤，例如 "home_banner"
- 返回：活跃状态的广告列表，按 `sort_order` 升序和 `created_at` 降序排列

#### 3. 实体类
位置：`Backend/src/main/java/com/bookstore/entity/Advertisement.java`

### 前端（Flutter App）

#### 1. 数据模型
位置：`App/lib/src/features/home/data/models/advertisement.dart`

#### 2. API服务
位置：`App/lib/src/features/home/data/advertisement_api_service.dart`
- 提供 `getAdvertisements()` 方法获取广告列表

#### 3. Provider
位置：`App/lib/src/features/home/providers/advertisements_provider.dart`
- `homeBannerAdvertisementsProvider`：提供首页横幅广告数据

#### 4. UI组件
位置：`App/lib/src/features/home/presentation/widgets/home_banner.dart`

功能特性：
- 自动轮播（5秒间隔）
- 支持点击跳转
- 加载状态展示
- 错误处理
- 空数据隐藏

## 使用说明

### 后端使用

#### 1. 通过管理后台添加广告

使用Admin API添加新广告：

```bash
POST /api/admin/advertisements
Content-Type: application/json

{
  "title": "新书推荐",
  "imageUrl": "https://example.com/banner1.jpg",
  "targetType": "book",
  "targetId": 1,
  "position": "home_banner",
  "sortOrder": 0,
  "isActive": true
}
```

#### 2. 广告类型说明

**跳转到书籍**：
```json
{
  "targetType": "book",
  "targetId": 123,
  "targetUrl": null
}
```

**跳转到URL**：
```json
{
  "targetType": "url",
  "targetId": null,
  "targetUrl": "https://example.com/promotion"
}
```

**无跳转**：
```json
{
  "targetType": "none",
  "targetId": null,
  "targetUrl": null
}
```

#### 3. 广告排序

- 设置 `sortOrder` 字段控制广告顺序
- 数值越小越靠前
- 相同 `sortOrder` 时，按创建时间降序排列

### 前端使用

广告组件已集成到首页，无需额外配置。

如需在其他页面使用广告：

```dart
import 'package:book_store/src/features/home/presentation/widgets/home_banner.dart';

// 在需要展示广告的地方
const HomeBanner()
```

## API端点总结

| 端点 | 方法 | 用途 | 权限 |
|------|------|------|------|
| `/api/advertisements` | GET | 获取活跃广告 | 公开 |
| `/api/admin/advertisements` | GET | 获取广告列表（分页） | Admin |
| `/api/admin/advertisements` | POST | 创建广告 | Admin |
| `/api/admin/advertisements/{id}` | GET | 获取广告详情 | Admin |
| `/api/admin/advertisements/{id}` | PUT | 更新广告 | Admin |
| `/api/admin/advertisements/{id}` | DELETE | 删除广告 | Admin |
| `/api/admin/advertisements/{id}/toggle` | PUT | 切换广告状态 | Admin |

## 依赖项

### Flutter依赖
- `carousel_slider`: ^5.1.1 - 轮播组件
- `cached_network_image`: ^3.4.1 - 图片缓存
- `url_launcher`: ^6.3.1 - 打开外部链接

已在 `pubspec.yaml` 中配置完成。

## 注意事项

1. **图片URL**：确保 `imageUrl` 是可访问的有效URL
2. **广告尺寸**：建议使用 2.5:1 的横幅图片比例（如 800x320）
3. **跳转验证**：设置 `targetType` 为 "book" 时，必须提供有效的 `targetId`
4. **性能优化**：使用 `CachedNetworkImage` 实现图片缓存，避免重复加载
5. **错误处理**：广告加载失败时会优雅降级，不影响页面其他功能

## 测试建议

1. 添加多个广告测试轮播效果
2. 测试不同 `targetType` 的跳转逻辑
3. 测试广告启用/禁用功能
4. 测试空广告列表情况
5. 测试图片加载失败情况

## 未来扩展

可以考虑添加以下功能：
- 广告点击统计
- 广告展示次数统计
- 多位置广告支持（弹窗、底部等）
- 定时上下架功能
- A/B测试支持
