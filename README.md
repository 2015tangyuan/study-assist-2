# 幼儿园英语学习助手

> 专为3-6岁幼儿园小朋友设计的英语学习辅助工具

## 📋 项目简介

这是一个专为3-6岁幼儿园小朋友设计的英语学习辅助工具，通过"听音选图"的趣味互动形式，帮助幼儿学习英语单词，构建"老师配置-学生练习-数据反馈"的完整教学闭环。

### ✨ 核心特性

- 🎯 **听音选图**: 趣味互动的学习方式
- 📱 **移动端适配**: 完美适配手机、平板
- 💻 **教师管理后台**: 完整的班级、题库、作业管理
- 📊 **学情分析**: 详细的学习数据统计和分析
- 🔐 **权限控制**: 三级权限体系（学生、教师、管理员）
- 🚀 **零代码后端**: 使用Supabase，无需编写后端代码
- 💰 **完全免费**: 使用Vercel和Supabase免费额度

## 🎯 功能预览

### 学生移动端

- 用户认证（手机号验证码登录、游客模式）
- 首页（个人信息、今日作业、学习数据）
- 听音选图练习（音频播放、选项选择、即时反馈）
- 作业结果（得分展示、答题详情、老师评语）
- 学习报告（学习趋势、薄弱知识点、班级对比）
- 个人中心（学习统计、成就系统）

### 教师PC端

- 控制台（数据概览、近期作业、待办事项）
- 班级管理（创建班级、学生管理、家长绑定）
- 题库管理（单词录入、分类管理、批量导入）
- 作业发布（手动选题、自动组题、作业预览）
- 作业管理（查看进度、批改作业、添加评语）
- 学情分析（班级分析、学生分析、作业分析）

## 技术栈

- **前端框架**: Vue 3 + Vite
- **UI组件库**: 
  - 移动端: Vant
  - PC端: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router
- **后端服务**: Supabase (零代码后端)
- **部署平台**: Vercel

## 🚀 快速开始

### 方式一：在线IDE开发（推荐，无需安装）

1. **打开在线IDE**
   - 访问 https://stackblitz.com/
   - 点击 "Create New Project"
   - 选择 "Vue" 模板

2. **复制项目文件**
   - 将本项目的所有文件复制到在线IDE中
   - 或者直接导入GitHub仓库

3. **配置环境变量**
   - 创建 `.env` 文件
   - 添加Supabase配置（见下方）

### 方式二：本地开发（需要Node.js）

1. **安装依赖**
```bash
npm install
```

2. **启动开发服务器**
```bash
npm run dev
```

3. **访问应用**
   - 学生端: http://localhost:3000/student
   - 教师端: http://localhost:3000/teacher

## ⚙️ 配置Supabase

### 1. 创建Supabase项目

1. 访问 https://supabase.com/
2. 注册账号并登录
3. 点击 "New Project"
4. 填写项目信息并创建

### 2. 获取API密钥

1. 在Supabase项目中，点击 "Settings" → "API"
2. 复制 `Project URL` 和 `anon public key`

### 3. 创建数据库表

1. 在Supabase项目中，点击 "SQL Editor"
2. 点击 "New Query"
3. 复制 `docs/database-schema.sql` 文件中的SQL语句
4. 粘贴并执行

### 4. 配置环境变量

在项目根目录创建 `.env` 文件：

```env
VITE_SUPABASE_URL=你的Project URL
VITE_SUPABASE_ANON_KEY=你的anon public key
```

## 📚 详细文档

- [快速开始指南](./docs/QUICKSTART.md) - 30分钟快速部署
- [部署指南](./docs/DEPLOYMENT.md) - 详细部署步骤
- [项目总结](./docs/PROJECT_SUMMARY.md) - 项目功能总结
- [数据库结构](./docs/database-schema.sql) - 数据库设计

## 项目结构

```
study-assist/
├── src/
│   ├── views/              # 页面组件
│   │   ├── student/        # 学生端页面
│   │   │   ├── Login.vue   # 登录页
│   │   │   ├── Home.vue    # 首页
│   │   │   ├── Practice.vue # 练习页
│   │   │   ├── Result.vue  # 结果页
│   │   │   ├── Report.vue  # 学习报告
│   │   │   └── Profile.vue # 个人中心
│   │   └── teacher/        # 教师端页面
│   │       ├── Login.vue   # 登录页
│   │       ├── Dashboard.vue # 控制台
│   │       ├── Classes.vue # 班级管理
│   │       ├── Questions.vue # 题库管理
│   │       ├── Assignments.vue # 作业管理
│   │       └── Analysis.vue # 学情分析
│   ├── components/         # 公共组件
│   ├── stores/            # 状态管理
│   │   └── user.js        # 用户状态
│   ├── router/            # 路由配置
│   │   └── index.js
│   ├── config/            # 配置文件
│   │   └── supabase.js    # Supabase配置
│   ├── App.vue            # 根组件
│   └── main.js            # 入口文件
├── docs/                  # 文档
│   └── database-schema.sql # 数据库结构
├── public/                # 静态资源
├── index.html             # HTML模板
├── vite.config.js         # Vite配置
├── package.json           # 项目配置
└── README.md              # 项目说明
```

## 开发流程

### 学生端开发

1. **登录功能**
   - 手机号验证码登录
   - 游客模式体验

2. **首页功能**
   - 展示个人信息
   - 今日作业卡片
   - 学习数据统计
   - 历史作业列表

3. **练习功能**
   - 听音选图
   - 进度显示
   - 答题反馈
   - 题目切换

4. **结果功能**
   - 得分展示
   - 答题详情
   - 老师评语

5. **报告功能**
   - 学习趋势
   - 薄弱知识点
   - 班级对比

### 教师端开发

1. **控制台**
   - 数据概览
   - 近期作业
   - 待办事项

2. **班级管理**
   - 创建班级
   - 学生管理
   - 家长绑定

3. **题库管理**
   - 单词录入
   - 分类管理
   - 批量导入

4. **作业管理**
   - 发布作业
   - 查看进度
   - 批改作业

5. **学情分析**
   - 班级分析
   - 学生分析
   - 知识点分析

## 部署上线

### 1. 部署前端到Vercel

1. 将项目代码推送到GitHub
2. 访问 https://vercel.com/
3. 使用GitHub账号登录
4. 点击 "New Project"
5. 选择你的GitHub仓库
6. 配置环境变量：
   - VITE_SUPABASE_URL
   - VITE_SUPABASE_ANON_KEY
7. 点击 "Deploy"

### 2. 配置自定义域名（可选）

1. 在Vercel项目中，点击 "Settings" → "Domains"
2. 添加你的域名
3. 按照提示配置DNS

## 常见问题

### Q: 如何添加新的题目？

A: 
1. 准备音频文件（MP3格式）
2. 准备图片文件（JPG/PNG格式）
3. 在Supabase的Storage中上传文件
4. 在Table Editor中添加题目记录

### Q: 如何修改界面样式？

A:
- 学生端样式在对应的Vue文件中修改
- 使用Vant组件库的样式变量进行全局配置
- 修改颜色主题：在 `src/App.vue` 中修改CSS变量

### Q: 如何添加新功能？

A:
1. 在 `src/views/` 中创建新的页面组件
2. 在 `src/router/index.js` 中添加路由
3. 在Supabase中创建相应的数据表
4. 实现业务逻辑

## 技术支持

- Vue 3文档: https://vuejs.org/
- Vant文档: https://vant-ui.github.io/
- Element Plus文档: https://element-plus.org/
- Supabase文档: https://supabase.com/docs
- Vercel文档: https://vercel.com/docs

## 许可证

MIT License
