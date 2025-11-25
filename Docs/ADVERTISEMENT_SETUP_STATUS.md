# 广告功能设置状态

## ✅ 已完成的工作

### 1. 后端（Backend）
- ✅ 创建客户端广告API接口：`ClientAdvertisementController.java`
  - 路径：`GET /api/advertisements`
  - 支持按位置过滤参数：`?position=home_banner`
  - 返回活跃广告列表（按排序和创建时间排序）
- ✅ 数据库表已存在：`advertisements` 表
- ✅ Entity类已存在：`Advertisement.java`
- ✅ Repository已存在：`AdvertisementRepository.java`
- ✅ 后端编译成功

### 2. 前端（Flutter App）
- ✅ 创建广告数据模型：`advertisement.dart`
- ✅ 创建广告API服务：`advertisement_api_service.dart`（已添加错误处理和null安全）
- ✅ 创建广告Provider：`advertisements_provider.dart`
- ✅ 更新首页广告轮播组件：`home_banner.dart`
  - 支持自动轮播（5秒间隔）
  - 支持三种跳转类型：书籍、URL、无跳转
  - 完善的错误处理和空数据处理
- ✅ 添加必要依赖：`url_launcher: ^6.3.1`
- ✅ 运行代码生成器
- ✅ Flutter代码分析通过

## 📋 下一步需要做的事情

### 1. 数据库初始化
确保 `advertisements` 表已创建。如果没有，运行以下SQL：

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
  PRIMARY KEY (`id`),
  KEY `idx_position` (`position`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_target_id` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Advertisement Table';
```

### 2. 添加测试广告数据

通过Admin后台或直接通过SQL添加测试数据：

```sql
INSERT INTO `advertisements`
  (`title`, `image_url`, `target_type`, `target_id`, `target_url`, `position`, `sort_order`, `is_active`)
VALUES
  ('测试广告1 - 跳转书籍', 'https://picsum.photos/800/320?random=1', 'book', 1, NULL, 'home_banner', 0, 1),
  ('测试广告2 - 跳转URL', 'https://picsum.photos/800/320?random=2', 'url', NULL, 'https://www.example.com', 'home_banner', 1, 1),
  ('测试广告3 - 无跳转', 'https://picsum.photos/800/320?random=3', 'none', NULL, NULL, 'home_banner', 2, 1);
```

### 3. 启动后端服务器

```bash
cd Backend
mvn spring-boot:run
```

确保服务器在正确的端口运行（通常是8080）。

### 4. 配置Flutter API基础URL

检查 `App/lib/src/services/networking/dio_provider.dart` 文件，确保baseUrl配置正确：

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://your-backend-url:8080', // 修改为实际的后端地址
  // ...
));
```

### 5. 测试广告功能

1. 启动Flutter应用
2. 进入首页
3. 查看顶部广告轮播
4. 测试点击不同类型的广告：
   - 点击书籍类型广告应跳转到书籍详情页
   - 点击URL类型广告应打开外部浏览器
   - 点击无跳转类型广告无反应

## 🐛 常见问题排查

### 问题1：广告不显示
**可能原因**：
- 数据库中没有广告数据
- 广告的 `is_active` 字段为0（未激活）
- 广告的 `position` 字段不是 'home_banner'
- 后端API未正确返回数据

**排查步骤**：
1. 检查数据库：`SELECT * FROM advertisements WHERE is_active = 1 AND position = 'home_banner';`
2. 测试后端API：访问 `http://localhost:8080/api/advertisements?position=home_banner`
3. 查看Flutter调试日志中的错误信息

### 问题2：类型转换错误
**错误信息**：`type 'Null' is not a subtype of type 'List<dynamic>' in type cast`

**解决方案**：
- 已在 `advertisement_api_service.dart` 中添加了null安全检查
- 如果仍有问题，检查后端返回的数据格式是否正确

### 问题3：图片不显示
**可能原因**：
- 图片URL无效或无法访问
- 网络连接问题
- CORS问题（如果是Web版本）

**解决方案**：
- 使用可访问的图片URL（建议使用CDN或公共图床）
- 检查网络连接
- 确保图片服务器允许跨域访问

## 📝 API调用示例

### 获取所有活跃广告
```
GET http://localhost:8080/api/advertisements
```

响应示例：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "title": "测试广告1",
      "imageUrl": "https://example.com/banner1.jpg",
      "targetType": "book",
      "targetId": 1,
      "targetUrl": null,
      "position": "home_banner",
      "sortOrder": 0,
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00",
      "updatedAt": "2024-01-01T00:00:00"
    }
  ]
}
```

### 按位置过滤广告
```
GET http://localhost:8080/api/advertisements?position=home_banner
```

## 🔧 配置选项

### 广告轮播设置
在 `home_banner.dart` 中可以调整轮播参数：

```dart
CarouselOptions(
  height: 150.0,                    // 广告高度
  autoPlay: true,                   // 是否自动播放
  autoPlayInterval: const Duration(seconds: 5),  // 切换间隔
  autoPlayAnimationDuration: const Duration(milliseconds: 800),  // 动画时长
  // ...
)
```

### 广告位置
当前支持的位置：
- `home_banner` - 首页顶部横幅（已实现）
- 可扩展其他位置如：`home_popup`、`detail_banner` 等

## 📚 相关文档

详细的功能说明请参考：[ADVERTISEMENT_FEATURE.md](./ADVERTISEMENT_FEATURE.md)

## ✅ 验收清单

在标记广告功能为"完成"之前，请确认：

- [ ] 数据库表已创建
- [ ] 至少添加了3条测试广告数据
- [ ] 后端服务器可以正常启动
- [ ] 后端API返回正确的广告数据
- [ ] Flutter应用可以正常启动
- [ ] 首页可以正常显示广告轮播
- [ ] 广告自动轮播功能正常
- [ ] 点击书籍类型广告可以跳转到书籍详情
- [ ] 点击URL类型广告可以打开外部链接
- [ ] 无广告时组件自动隐藏
- [ ] 图片加载失败时显示错误图标
