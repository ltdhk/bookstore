# 书架功能快速开始指南

## 🎯 功能概述

书架功能现已完全本地化，所有数据保存在客户端，支持添加、查看和删除书籍。

## 🚀 快速测试

### 1. 运行应用

```bash
cd App
flutter pub get
flutter run
```

### 2. 测试添加书籍

1. 在首页点击任意书籍
2. 进入书籍详情页
3. 点击底部的 **"Add to Bookshelf"** 按钮
4. 看到提示 "Added to bookshelf"
5. 按钮变为 **"In Bookshelf"** （带勾选图标）

### 3. 查看书架

1. 点击底部导航栏的 **"Bookshelf"** 图标
2. 看到刚刚添加的书籍
3. 书籍按添加时间排序（最新的在前）

### 4. 测试删除功能

1. 在书架页面点击右上角 **"Edit"** 按钮
2. 点击书籍，会出现勾选框
3. 选择一本或多本书籍
4. 点击底部的 **"Delete"** 按钮
5. 在弹出对话框中确认删除
6. 书籍从列表中移除，显示 "Books removed from bookshelf"

### 5. 测试持久化

1. 添加几本书到书架
2. 完全关闭应用（不是后台运行）
3. 重新打开应用
4. 进入书架页面
5. ✅ 数据仍然存在！

## 📱 界面说明

### 书架页面

```
┌─────────────────────────────┐
│  ← Bookshelf                │  AppBar
│  🔍 Search...          Edit │  搜索框 + 编辑按钮
├─────────────────────────────┤
│  My bookshelf               │  标题
│                             │
│  📚 📚 📚                    │
│  书1 书2 书3                 │  书籍网格（3列）
│                             │
│  📚 📚 [+]                   │
│  书4 书5 添加                │
│                             │
└─────────────────────────────┘
```

### 编辑模式

```
┌─────────────────────────────┐
│  ← Bookshelf                │
│  🔍 Search...       Cancel  │  取消按钮
├─────────────────────────────┤
│  My bookshelf               │
│                             │
│  📚✓ 📚  📚✓                │  勾选框
│  书1  书2  书3              │  选中的书有勾选标记
│                             │
│  ┌─────────────────────┐   │
│  │      Delete         │   │  删除按钮（灰色=禁用）
│  └─────────────────────┘   │
└─────────────────────────────┘
```

### 书籍详情页

```
┌─────────────────────────────┐
│  ← 书名              ⋮ 分享 │
│                             │
│  📖     Reborn: No More     │
│  封面    Second Chances...  │
│         Ernest              │
│         ⭐ 4.8  2.3k Reads   │
│                             │
│  Description                │
│  This is a story about...   │
│                             │
│  ┌───────────┬───────────┐ │
│  │ Add to    │  Start    │ │  操作按钮
│  │ Bookshelf │  Reading  │ │
│  └───────────┴───────────┘ │
└─────────────────────────────┘
```

## 💡 使用技巧

### 添加书籍
- 从书籍详情页点击 "Add to Bookshelf"
- 已添加的书显示 "In Bookshelf"（可再次点击移除）

### 删除书籍
- **单本删除**: 编辑模式下选择一本书，点击Delete
- **批量删除**: 编辑模式下选择多本书，点击Delete
- **快速移除**: 在书籍详情页点击 "In Bookshelf" 按钮

### 查找书籍
- 点击搜索框跳转到搜索页面
- 书架书籍按时间排序，最新的在前面

## 🔧 开发者说明

### 代码位置

```
App/lib/src/features/bookshelf/
├── data/
│   └── bookshelf_local_storage.dart   # 本地存储实现
├── presentation/
│   └── bookshelf_screen.dart          # UI界面
└── providers/
    └── bookshelf_provider.dart        # 状态管理
```

### 在代码中使用

#### 添加书籍
```dart
await ref.read(bookshelfProvider.notifier).addBook(
  id: 'book-id',
  title: 'Book Title',
  author: 'Author Name',
  coverUrl: 'https://...',
  category: 'Fiction',
);
```

#### 检查书籍是否在书架
```dart
final isInShelf = ref.watch(isBookInBookshelfProvider('book-id'));
```

#### 删除书籍
```dart
// 删除单本
await ref.read(bookshelfProvider.notifier).removeBook('book-id');

// 批量删除
await ref.read(bookshelfProvider.notifier).removeBooks(['id1', 'id2']);
```

#### 获取书架列表
```dart
final bookshelfAsync = ref.watch(bookshelfProvider);
bookshelfAsync.when(
  data: (books) => Text('有 ${books.length} 本书'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('错误: $err'),
);
```

## 📝 数据说明

### 本地存储
- **数据库**: Hive
- **Box名称**: `bookshelf`
- **存储格式**: JSON
- **位置**: 应用数据目录（不同平台不同）

### 数据结构
```json
{
  "books": [
    {
      "id": "book-123",
      "title": "书名",
      "author": "作者",
      "coverUrl": "封面URL",
      "category": "分类",
      "addedAt": "2024-01-01T12:00:00.000Z"
    }
  ]
}
```

## ⚠️ 注意事项

1. **数据仅保存在本地**
   - 换设备数据不会同步
   - 卸载应用会清空数据

2. **重复添加**
   - 系统会自动检查，不会重复添加同一本书

3. **性能**
   - 已测试支持大量书籍（100+）
   - 使用网格布局优化滚动性能

## 🐛 常见问题

### Q: 数据会同步到云端吗？
A: 不会。当前版本完全本地存储，不涉及服务器交互。

### Q: 换手机后数据还在吗？
A: 不在。数据保存在本地，换设备需要重新添加。

### Q: 可以导出书架数据吗？
A: 当前版本暂不支持，可作为后续功能开发。

### Q: 卸载应用后重装，数据还在吗？
A: 不在。卸载会清空所有应用数据。

### Q: 添加书籍失败怎么办？
A: 检查：
- 应用是否有存储权限
- 设备存储空间是否充足
- 查看日志输出错误信息

## 📚 更多文档

- [详细使用说明](BOOKSHELF_USAGE.md)
- [实现总结](BOOKSHELF_IMPLEMENTATION_SUMMARY.md)

## ✅ 测试清单

- [ ] 添加第一本书
- [ ] 添加多本书
- [ ] 查看书架列表
- [ ] 进入编辑模式
- [ ] 删除单本书
- [ ] 批量删除书籍
- [ ] 退出编辑模式
- [ ] 从书籍详情页添加
- [ ] 从书籍详情页移除
- [ ] 关闭应用重新打开验证持久化
- [ ] 测试空书架状态
- [ ] 测试大量书籍（50+）

## 🎉 完成！

现在你可以开始使用完整的书架功能了！如有问题，请查看详细文档或联系开发团队。
