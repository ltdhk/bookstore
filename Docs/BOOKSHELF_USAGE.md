# 书架功能使用说明

## 概述

书架功能已完成以下改进：
1. **本地存储**：书架数据现在完全保存在客户端本地（使用Hive），无需与服务端交互
2. **删除功能**：实现了完整的书籍删除功能，支持单本和批量删除

## 功能特性

### 1. 本地数据存储
- 使用Hive数据库在本地存储书架数据
- 数据持久化，应用重启后数据不丢失
- 按添加时间排序，最新添加的书籍显示在前面

### 2. 书架管理
- 查看所有收藏的书籍
- 编辑模式下选择多本书籍
- 批量删除选中的书籍
- 点击书籍进入详情页

## 使用方法

### 添加书籍到书架

```dart
import 'package:book_store/src/features/bookshelf/providers/bookshelf_provider.dart';

// 在Widget中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        await ref.read(bookshelfProvider.notifier).addBook(
          id: 'book-123',
          title: '书名',
          author: '作者',
          coverUrl: 'https://example.com/cover.jpg',
          category: '分类',
        );
      },
      child: Text('添加到书架'),
    );
  }
}
```

### 检查书籍是否在书架中

```dart
// 使用Provider检查
final isInBookshelf = ref.watch(isBookInBookshelfProvider('book-123'));

if (isInBookshelf) {
  // 书籍已在书架中
}
```

### 删除单本书籍

```dart
await ref.read(bookshelfProvider.notifier).removeBook('book-123');
```

### 批量删除书籍

```dart
await ref.read(bookshelfProvider.notifier).removeBooks([
  'book-123',
  'book-456',
  'book-789',
]);
```

### 清空书架

```dart
await ref.read(bookshelfProvider.notifier).clearAll();
```

### 获取书架书籍数量

```dart
final count = ref.watch(bookshelfCountProvider);
```

## 数据结构

### BookshelfItem

```dart
class BookshelfItem {
  final String id;         // 书籍ID
  final String title;      // 书名
  final String author;     // 作者
  final String coverUrl;   // 封面URL
  final String category;   // 分类
  final DateTime addedAt;  // 添加时间
}
```

## 文件结构

```
lib/src/features/bookshelf/
├── data/
│   ├── bookshelf_api_service.dart      # API服务（已弃用）
│   ├── bookshelf_local_storage.dart    # 本地存储服务
│   └── bookshelf_local_storage.g.dart  # 生成的代码
├── presentation/
│   └── bookshelf_screen.dart           # 书架UI界面
└── providers/
    ├── bookshelf_provider.dart         # 状态管理Provider
    └── bookshelf_provider.g.dart       # 生成的代码
```

## UI功能说明

### 书架界面功能

1. **查看模式**（默认）
   - 显示所有收藏的书籍
   - 点击书籍进入详情页
   - 显示"添加书籍"按钮（占位）

2. **编辑模式**
   - 点击右上角"Edit"按钮进入编辑模式
   - 可选择多本书籍（点击书籍显示勾选框）
   - 底部显示"Delete"按钮
   - 点击"Delete"弹出确认对话框
   - 确认后删除选中的书籍

3. **搜索功能**
   - 顶部搜索框可跳转到搜索页面

## 技术实现

### 状态管理
使用Riverpod进行状态管理：
- `bookshelfProvider`: 提供书架书籍列表
- `isBookInBookshelfProvider`: 检查书籍是否在书架中
- `bookshelfCountProvider`: 提供书架书籍数量

### 本地存储
使用Hive进行数据持久化：
- Box名称: `bookshelf`
- 存储格式: JSON
- 自动排序: 按添加时间降序

## 测试方法

1. **添加书籍测试**
   - 从首页或书籍详情页添加书籍到书架
   - 检查书架页面是否显示新添加的书籍

2. **删除功能测试**
   - 进入书架页面
   - 点击"Edit"按钮进入编辑模式
   - 选择一本或多本书籍
   - 点击"Delete"按钮
   - 确认删除
   - 验证书籍已被删除

3. **持久化测试**
   - 添加一些书籍到书架
   - 完全关闭应用
   - 重新打开应用
   - 验证书架数据仍然存在

## 注意事项

1. 书架数据完全存储在本地，不会同步到服务器
2. 卸载应用会清空所有书架数据
3. 如需实现跨设备同步，需要额外实现云端同步功能
4. 目前"添加书籍"按钮为占位功能，需要集成到书籍详情页

## 后续优化建议

1. **云端同步**
   - 可选实现书架数据的云端备份和同步
   - 用户登录后自动同步

2. **分类管理**
   - 支持按分类筛选书架书籍
   - 支持自定义书架分组

3. **排序方式**
   - 支持按标题、作者、添加时间等排序
   - 支持手动调整书籍顺序

4. **导入导出**
   - 支持导出书架数据
   - 支持从其他设备导入书架数据

5. **统计信息**
   - 显示书架总数量
   - 显示各分类书籍数量
   - 阅读进度统计
