# 部署执行清单

## 📋 准备工作

在开始部署之前，请确保您有以下准备：

- [ ] 一个有效的邮箱地址
- [ ] 一个GitHub账号（如果没有，请先注册：https://github.com/）
- [ ] 一个手机号（用于测试短信登录）

## 🚀 部署步骤

### 第1步：创建Supabase项目（预计5分钟）

#### 1.1 注册并登录
1. 打开浏览器，访问 https://supabase.com/
2. 点击右上角 "Start your project"
3. 选择使用GitHub账号登录（推荐）
4. 授权GitHub登录

#### 1.2 创建新项目
1. 登录后，点击 "New Project"
2. 填写以下信息：
   - **Name**: `study-assist`
   - **Database Password**: 设置一个强密码（请记住这个密码！建议保存到记事本）
     - 示例：`Study@Assist2024`
   - **Region**: 选择 `Southeast Asia (Singapore)`（离中国最近的区域）
   - **Pricing Plan**: 选择 `Free`（免费版）
3. 点击 "Create new project"
4. 等待项目创建完成（约2-3分钟）
   - 您会看到 "Setting up your project..." 的进度条
   - 完成后会自动跳转到项目仪表板

#### 1.3 获取API密钥
1. 在左侧菜单点击 `Settings` → `API`
2. 您会看到以下信息：
   - **Project URL**: 类似 `https://xxxxx.supabase.co`
   - **anon public key**: 类似 `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
3. **重要**：复制这两个值并保存到记事本，后面会用到

### 第2步：创建数据库表（预计3分钟）

#### 2.1 打开SQL编辑器
1. 在左侧菜单点击 `SQL Editor`
2. 点击 `New Query` 按钮

#### 2.2 执行数据库脚本
1. 打开项目文件夹中的 `docs/database-schema.sql` 文件
2. 复制文件中的所有SQL内容（Ctrl+A，然后Ctrl+C）
3. 回到Supabase的SQL编辑器
4. 粘贴SQL内容（Ctrl+V）
5. 点击右下角的 `Run` 按钮
6. 等待执行完成（约10-20秒）
7. 您应该看到 "Success. No rows returned" 的提示

### 第3步：配置存储桶（预计2分钟）

#### 3.1 创建音频存储桶
1. 在左侧菜单点击 `Storage`
2. 点击 `New bucket`
3. 填写信息：
   - **Name**: `audio`
   - **Public bucket**: 勾选（设置为公开）
4. 点击 `Create bucket`

#### 3.2 创建图片存储桶
1. 再次点击 `New bucket`
2. 填写信息：
   - **Name**: `images`
   - **Public bucket**: 勾选（设置为公开）
3. 点击 `Create bucket`

### 第4步：配置项目环境变量（预计2分钟）

#### 4.1 创建.env文件
1. 打开项目文件夹：`d:\TRAE 开发项目\study asist\`
2. 使用文本编辑器（如记事本）创建新文件
3. 保存为 `.env`（注意前面有个点）
4. 复制以下内容并粘贴：

```env
VITE_SUPABASE_URL=你的Project URL
VITE_SUPABASE_ANON_KEY=你的anon public key
```

#### 4.2 填写实际值
1. 将 `你的Project URL` 替换为第1步中复制的Project URL
   - 示例：`VITE_SUPABASE_URL=https://xxxxx.supabase.co`
2. 将 `你的anon public key` 替换为第1步中复制的anon public key
   - 示例：`VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
3. 保存文件

### 第5步：推送代码到GitHub（预计5分钟）

#### 5.1 创建GitHub仓库
1. 访问 https://github.com/
2. 登录您的账号
3. 点击右上角 `+` → `New repository`
4. 填写信息：
   - **Repository name**: `study-assist`
   - **Description**: 幼儿园英语学习助手
   - **Public/Private**: 选择 `Public`（公开）或 `Private`（私有）
5. 点击 `Create repository`

#### 5.2 初始化Git仓库
1. 打开命令提示符（CMD）或PowerShell
2. 进入项目目录：
```bash
cd "d:\TRAE 开发项目\study asist"
```

3. 初始化Git仓库：
```bash
git init
```

4. 添加所有文件：
```bash
git add .
```

5. 提交更改：
```bash
git commit -m "Initial commit: 幼儿园英语学习助手项目"
```

6. 添加远程仓库（替换为你的GitHub用户名）：
```bash
git remote add origin https://github.com/你的用户名/study-assist.git
```

7. 推送到GitHub：
```bash
git branch -M main
git push -u origin main
```

8. 如果提示输入用户名和密码：
   - 用户名：GitHub用户名
   - 密码：使用GitHub Personal Access Token（不是登录密码）
     - 获取方式：GitHub Settings → Developer settings → Personal access tokens → Generate new token

### 第6步：在Vercel部署（预计5分钟）

#### 6.1 注册并登录Vercel
1. 访问 https://vercel.com/
2. 点击 `Sign Up`
3. 选择使用GitHub账号登录
4. 授权Vercel访问您的GitHub

#### 6.2 导入项目
1. 登录后，点击 `Add New...` → `Project`
2. 在 "Import Git Repository" 中找到 `study-assist` 仓库
3. 点击 `Import`

#### 6.3 配置项目
1. **Framework Preset**: 选择 `Vite`
2. **Root Directory**: 保持 `./`
3. **Build Command**: 保持 `npm run build`
4. **Output Directory**: 保持 `dist`

#### 6.4 添加环境变量
1. 向下滚动到 "Environment Variables" 部分
2. 点击 `Add New`
3. 添加第一个变量：
   - **Name**: `VITE_SUPABASE_URL`
   - **Value**: 粘贴你的Project URL
4. 点击 `Add New` 添加第二个变量：
   - **Name**: `VITE_SUPABASE_ANON_KEY`
   - **Value**: 粘贴你的anon public key

#### 6.5 部署
1. 点击底部的 `Deploy` 按钮
2. 等待部署完成（约2-3分钟）
3. 您会看到构建进度
4. 部署成功后，会显示一个绿色的对勾
5. 点击 `Visit` 按钮访问部署的应用

### 第7步：测试应用（预计10分钟）

#### 7.1 测试学生端
1. 访问：`https://你的项目名.vercel.app/student`
   - 例如：`https://study-assist.vercel.app/student`
2. 测试功能：
   - [ ] 点击"游客模式体验"
   - [ ] 查看首页展示
   - [ ] 测试底部导航栏切换

#### 7.2 测试教师端
1. 访问：`https://你的项目名.vercel.app/teacher`
   - 例如：`https://study-assist.vercel.app/teacher`
2. 测试功能：
   - [ ] 查看登录页面
   - [ ] 测试界面响应

### 第8步：创建测试数据（预计5分钟）

#### 8.1 创建教师账号
1. 回到Supabase项目
2. 点击左侧菜单 `Authentication` → `Users`
3. 点击 `Add user`
4. 填写信息：
   - **Email**: `teacher@example.com`
   - **Password**: 设置密码（如：`Teacher123`）
   - **Auto Confirm User**: 勾选
5. 点击 `Create user`
6. 点击新创建的用户，查看 `user_id`（复制保存）

#### 8.2 创建班级
1. 点击左侧菜单 `Table Editor`
2. 选择 `classes` 表
3. 点击 `Insert row`
4. 填写信息：
   - **teacher_id**: 粘贴上面复制的user_id
   - **name**: `大一班`
   - **grade**: `大班`
   - **invite_code**: `ABC123`
5. 点击 `Save`

#### 8.3 创建测试学生
1. 选择 `students` 表
2. 点击 `Insert row`
3. 填写信息：
   - **name**: `测试学生`
   - **class_id**: 选择刚创建的班级ID
   - **level**: `1`
4. 点击 `Save`

### 第9步：完整功能测试（预计15分钟）

#### 9.1 教师端测试
1. 访问教师端并登录
   - Email: `teacher@example.com`
   - Password: `Teacher123`
2. 测试功能：
   - [ ] 查看控制台数据
   - [ ] 创建新班级
   - [ ] 添加学生
   - [ ] 录入题目（需要准备音频和图片）
   - [ ] 发布作业

#### 9.2 学生端测试
1. 访问学生端
2. 测试功能：
   - [ ] 游客模式体验
   - [ ] 查看作业
   - [ ] 完成练习
   - [ ] 查看结果

## ✅ 完成检查清单

部署完成后，请确认以下项目：

### 基础设施
- [ ] Supabase项目创建成功
- [ ] 数据库表创建成功
- [ ] 存储桶配置完成
- [ ] Vercel部署成功
- [ ] 应用可以正常访问

### 学生端功能
- [ ] 登录/注册功能正常
- [ ] 首页展示正常
- [ ] 练习功能正常
- [ ] 结果展示正常
- [ ] 学习报告正常
- [ ] 个人中心正常

### 教师端功能
- [ ] 登录功能正常
- [ ] 控制台显示正常
- [ ] 班级管理功能正常
- [ ] 题库管理功能正常
- [ ] 作业发布功能正常
- [ ] 学情分析功能正常

## 🎯 后续优化建议

部署完成后，您可以考虑：

1. **添加更多内容**
   - 录入更多题目
   - 准备更多音频和图片
   - 创建更多班级

2. **优化用户体验**
   - 根据实际使用调整界面
   - 优化题目难度
   - 改进学习路径

3. **推广使用**
   - 邀请学生使用
   - 收集用户反馈
   - 持续改进功能

## 📞 遇到问题？

如果遇到问题，请：

1. 查看浏览器控制台错误（F12）
2. 检查环境变量是否正确配置
3. 确认Supabase项目是否正常运行
4. 查看Vercel部署日志

## 🎉 恭喜！

完成以上步骤后，您的"幼儿园英语学习助手"就成功上线了！

现在您可以：
- ✅ 让学生通过手机访问应用进行学习
- ✅ 让教师通过PC端管理班级和作业
- ✅ 所有数据都安全地存储在云端
- ✅ 完全免费，无需维护服务器

祝您使用愉快！
