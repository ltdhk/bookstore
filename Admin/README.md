# BookStore 管理后台

PC 端管理后台系统,用于管理书籍、用户、订单等。

## 快速开始

### 前置要求
- Node.js 18+
- MySQL 8.0+
- Java 17+
- Maven 3.6+

### 启动后端
```bash
cd Backend
mvn spring-boot:run
```
后端运行在 `http://localhost:8080`

### 启动前端
```bash
cd Admin
npm install
npm run dev
```
前端运行在 `http://localhost:5173`

### 默认管理员账号
- 用户名: `admin`
- 密码: `admin123`

## 技术栈

### 前端
- React 18 + TypeScript
- Ant Design 5
- Vite
- Zustand (状态管理)
- i18next (国际化)

### 后端
- Spring Boot 3.2.3
- MyBatis-Plus
- MySQL
- JWT 认证

## 主要功能

- ✅ 管理员登录
- ✅ 仪表盘统计
- ✅ 书籍管理 (CRUD)
- ✅ 用户管理
- ✅ 订单管理
- ✅ 中英文切换

## 项目结构

```
Admin/
├── src/
│   ├── api/          # API 接口
│   ├── layouts/      # 布局组件
│   ├── pages/        # 页面组件
│   ├── locales/      # 国际化
│   └── store/        # 状态管理
└── vite.config.ts

Backend/
└── src/main/java/com/bookstore/
    ├── controller/admin/  # 管理端控制器
    ├── entity/           # 实体类
    ├── service/          # 业务逻辑
    └── config/           # 配置类
```

## 开发说明

前端代理配置已设置,开发时前端会自动代理 `/api` 请求到后端 `http://localhost:8080`。

更多详细信息请查看 [演示文档](../walkthrough.md)。
