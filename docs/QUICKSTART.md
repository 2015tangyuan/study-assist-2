# 快速开始指南

欢迎使用"幼儿园英语学习助手"！本指南将帮助您在30分钟内完成项目的部署和运行。

## 📋 准备工作

在开始之前，请确保您有以下准备：

- ✅ 一个有效的邮箱地址
- ✅ 一个GitHub账号（如果没有，请先注册：https://github.com/）
- ✅ 一个手机号（用于测试短信登录）

## 🚀 快速部署步骤

### 第1步：创建Supabase项目（5分钟）

1. **访问Supabase**
   - 打开 https://supabase.com/
   - 点击 "Start your project"
   - 使用GitHub账号登录

2. **创建新项目**
   - 点击 "New Project"
   - 填写信息：
     - Name: `study-assist`
     - Database Password: 设置一个强密码（请记住！）
     - Region: 选择 `Southeast Asia (Singapore)`
   - 点击 "Create new project"
   - 等待2-3分钟

3. **获取API密钥**
   - 点击左侧菜单 `Settings` → `API`
   - 复制并保存以下两个值：
     - `Project URL`
     - `anon public key`

### 第2步：设置数据库（5分钟）

1. **创建数据表**
   - 点击左侧菜单 `SQL Editor`
   - 点击 `New Query`
   - 打开项目中的 `docs/database-schema.sql` 文件
   - 复制所有SQL内容
   - 粘贴到SQL编辑器
   - 点击 `Run` 按钮
   - 等待执行完成

2. **创建存储桶**
   - 点击左侧菜单 `Storage`
   - 点击 `New bucket`
   - 创建名为 `audio` 的桶（存储音频）
   - 创建名为 `images` 的桶（存储图片）
   - 将两个桶都设置为 `Public`

### 第3步：配置前端（5分钟）

1. **创建环境变量文件**
   - 在项目根目录创建 `.env` 文件
   - 复制以下内容并替换为你的实际值：

```env
VITE_SUPABASE_URL=你的Project URL
VITE_SUPABASE_ANON_KEY=你的anon public key
```

2. **测试本地运行（可选）**
   - 如果您安装了Node.js，可以本地测试：
   ```bash
   npm install
   npm run dev
   ```
   - 访问 http://localhost:3000

### 第4步：部署到Vercel（10分钟）

1. **推送到GitHub**
   - 在GitHub上创建新仓库 `study-assist`
   - 在项目目录执行：
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/你的用户名/study-assist.git
   git push -u origin main
   ```

2. **在Vercel部署**
   - 访问 https://vercel.com/
   - 使用GitHub账号登录
   - 点击 `Add New...` → `Project`
   - 选择你的GitHub仓库
   - 配置：
     - Framework Preset: `Vite`
     - Build Command: `npm run build`
     - Output Directory: `dist`
   - 添加环境变量：
     - `VITE_SUPABASE_URL`: 你的Project URL
     - `VITE_SUPABASE_ANON_KEY`: 你的anon public key
   - 点击 `Deploy`
   - 等待2-3分钟

3. **访问应用**
   - 部署成功后，Vercel会提供一个URL
   - 点击访问即可使用

## 📱 使用指南

### 学生端使用

1. **访问学生端**
   - 在浏览器中访问：`https://你的域名/student`

2. **登录**
   - 点击"游客模式体验"快速体验
   - 或使用手机号+验证码登录（需要配置短信服务）

3. **开始学习**
   - 查看今日作业
   - 点击"开始作业"
   - 听音选图完成练习
   - 查看结果和学习报告

### 教师端使用

1. **访问教师端**
   - 在浏览器中访问：`https://你的域名/teacher`

2. **创建教师账号**
   - 在Supabase的 `Authentication` → `Users` 中创建
   - Email: `teacher@example.com`
   - Password: 设置密码
   - User Metadata: `{"role": "teacher"}`

3. **开始使用**
   - 创建班级
   - 添加学生
   - 录入题目
   - 发布作业
   - 查看学情

## 🎯 核心功能测试清单

### 学生端测试

- [ ] 登录/注册功能
- [ ] 首页展示（个人信息、作业、统计数据）
- [ ] 听音选图练习
- [ ] 答题反馈
- [ ] 作业结果展示
- [ ] 学习报告查看

### 教师端测试

- [ ] 登录功能
- [ ] 班级管理（创建、编辑、删除）
- [ ] 学生管理（添加、编辑、删除）
- [ ] 题库管理（录入、审核、删除）
- [ ] 作业发布（手动选题、自动组题）
- [ ] 学情分析（班级分析、学生分析、作业分析）

## 📊 数据准备

### 准备示例题目

1. **准备音频文件**
   - 格式：MP3
   - 大小：每个文件不超过5MB
   - 内容：英文单词发音

2. **准备图片文件**
   - 格式：JPG或PNG
   - 大小：每个文件不超过2MB
   - 尺寸：建议300x200像素

3. **上传文件**
   - 在Supabase的 `Storage` 中
   - 将音频上传到 `audio` 桶
   - 将图片上传到 `images` 桶
   - 记录文件的URL

4. **录入题目**
   - 在教师端的"题库管理"中
   - 点击"添加题目"
   - 填写题目信息
   - 上传音频和图片
   - 提交审核

## 🔧 常见问题快速解决

### 问题1：部署后页面空白

**解决方案**：
1. 检查环境变量是否正确配置
2. 按F12打开浏览器控制台查看错误
3. 确认Supabase项目是否正常运行

### 问题2：登录失败

**解决方案**：
1. 检查Supabase认证是否启用
2. 确认短信服务商是否正确配置
3. 检查手机号格式是否正确

### 问题3：图片/音频无法加载

**解决方案**：
1. 确认Supabase存储桶是否设置为Public
2. 检查文件URL是否正确
3. 确认文件是否成功上传

### 问题4：如何添加更多题目

**解决方案**：
1. 准备音频和图片文件
2. 在Supabase Storage中上传
3. 在教师端"题库管理"中录入
4. 等待审核通过

## 📞 获取帮助

如果遇到问题，可以：

1. **查看文档**
   - [README.md](./README.md) - 项目说明
   - [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
   - [database-schema.sql](./database-schema.sql) - 数据库结构

2. **查看官方文档**
   - [Vue 3文档](https://vuejs.org/)
   - [Vant文档](https://vant-ui.github.io/)
   - [Element Plus文档](https://element-plus.org/)
   - [Supabase文档](https://supabase.com/docs)
   - [Vercel文档](https://vercel.com/docs)

3. **搜索解决方案**
   - 在Google或百度搜索错误信息
   - 在Stack Overflow上提问
   - 在GitHub上搜索类似问题

## 🎉 恭喜！

您已经成功部署了"幼儿园英语学习助手"！

现在您可以：

✅ 让学生通过手机访问应用进行学习
✅ 让教师通过PC端管理班级和作业
✅ 所有数据都安全地存储在云端
✅ 完全免费，无需维护服务器

## 📈 下一步建议

1. **完善内容**
   - 添加更多题目
   - 准备更多音频和图片
   - 创建更多班级

2. **优化体验**
   - 根据实际使用情况调整界面
   - 优化题目难度
   - 改进学习路径

3. **推广使用**
   - 邀请更多学生使用
   - 收集用户反馈
   - 持续改进功能

## 💡 提示

- 首次部署建议使用游客模式测试
- 生产环境请配置短信服务
- 定期备份Supabase数据
- 关注Vercel和Supabase的使用量

祝您使用愉快！🎊
