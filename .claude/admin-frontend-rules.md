# Admin Frontend Development Rules

## Modal Form Loading State (必须遵守)

所有管理后台页面的新增和编辑功能**必须**包含Loading状态，以提供良好的用户体验。

### 必需的实现要素

#### 1. State 定义
```typescript
const [submitLoading, setSubmitLoading] = useState(false);
```

#### 2. Submit Handler 实现
```typescript
const handleSubmit = async () => {
  try {
    setSubmitLoading(true);
    const values = await form.validateFields();

    if (editingItem) {
      await updateAPI(editingItem.id, values);
      message.success('更新成功');
    } else {
      await createAPI(values);
      message.success('创建成功');
    }

    setModalVisible(false);
    fetchData();
  } catch (error) {
    // 只在非表单验证错误时显示错误消息
    if (error instanceof Error && error.message !== 'Validation failed') {
      message.error('操作失败');
    }
  } finally {
    setSubmitLoading(false);
  }
};
```

#### 3. Modal 配置
```typescript
<Modal
  title={editingItem ? '编辑XXX' : '新增XXX'}
  open={modalVisible}
  onOk={handleSubmit}
  onCancel={() => {
    if (!submitLoading) {
      setModalVisible(false);
    }
  }}
  confirmLoading={submitLoading}
  maskClosable={!submitLoading}
  closable={!submitLoading}
>
  {/* Form content */}
</Modal>
```

### 关键要点

1. **confirmLoading**: 显示确认按钮的loading状态
2. **maskClosable**: Loading时禁止点击遮罩层关闭
3. **closable**: Loading时禁止点击关闭按钮
4. **onCancel**: 检查loading状态，防止提交过程中关闭
5. **finally**: 确保无论成功或失败都重置loading状态
6. **错误处理**: 区分表单验证错误和API错误，避免重复提示

### 参考实现

- ✅ 正确示例: `Admin/src/pages/Book/index.tsx`
- ✅ 正确示例: `Admin/src/pages/System/index.tsx` (TagManagementTab)

## 其他最佳实践

### 1. 表格Loading
```typescript
<Table
  loading={loading}
  dataSource={data}
  // ... other props
/>
```

### 2. 数据获取Loading
```typescript
const fetchData = async () => {
  setLoading(true);
  try {
    const res = await getAPI();
    setData(res);
  } catch (error) {
    message.error('获取数据失败');
  } finally {
    setLoading(false);
  }
};
```

### 3. 删除操作
```typescript
const handleDelete = async (id: number) => {
  try {
    await deleteAPI(id);
    message.success('删除成功');
    fetchData();
  } catch (error) {
    message.error('删除失败');
  }
};
```

## 执行检查清单

在开发或审查管理后台页面时，请确保：

- [ ] 新增/编辑Modal有submitLoading状态
- [ ] handleSubmit有完整的try-catch-finally
- [ ] Modal配置了confirmLoading、maskClosable、closable
- [ ] onCancel检查了submitLoading状态
- [ ] 表格配置了loading状态
- [ ] 所有异步操作都有适当的loading状态
- [ ] 错误消息区分了验证错误和API错误
