# 部署指南

本指南将帮助您将"幼儿园英语学习助手"项目部署到生产环境。

## 部署架构

```
┌─────────────────────────────────────────┐
│         Vercel (前端托管)              │
│  - 学生移动端 (H5)                     │
│  - 教师PC端 (Web)                     │
└──────────────┬────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│       Supabase (后端服务)              │
│  - PostgreSQL 数据库                   │
│  - 用户认证系统                         │
│  - 文件存储 (音频、图片)                │
│  - 实时数据同步                         │
└─────────────────────────────────────────┘
```

## 前置准备

### 1. 注册账号

- **GitHub账号**: https://github.com/ (用于代码托管)
- **Vercel账号**: https://vercel.com/ (用于前端部署)
- **Supabase账号**: https://supabase.com/ (用于后端服务)

### 2. 准备域名（可选）

如果您想使用自定义域名，请提前准备好：
- 域名（如: study-assist.com）
- 域名管理权限

## 第一步：创建Supabase项目

### 1.1 创建项目

1. 访问 https://supabase.com/
2. 点击右上角 "Start your project"
3. 使用GitHub账号登录
4. 点击 "New Project"
5. 填写项目信息：
   - **Name**: `study-assist`
   - **Database Password**: 设置一个强密码（请记住这个密码）
   - **Region**: 选择 `Southeast Asia (Singapore)` 或离您最近的区域
   - **Pricing Plan**: 选择 `Free`（免费版）
6. 点击 "Create new project"
7. 等待项目创建完成（约2-3分钟）

### 1.2 获取项目凭证

1. 在左侧菜单点击 `Settings` → `API`
2. 复制以下信息（保存到记事本）：
   - **Project URL**: 类似 `https://xxxx.supabase.co`
   - **anon public key**: 类似 `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 1.3 创建数据库表

1. 在左侧菜单点击 `SQL Editor`
2. 点击 `New Query`
3. 复制 `docs/database-schema.sql` 文件中的所有SQL语句
4. 粘贴到SQL编辑器中
5. 点击右下角 `Run` 按钮
6. 等待SQL执行完成

### 1.4 配置认证

1. 在左侧菜单点击 `Authentication` → `Providers`
2. 找到 `Phone` 选项，点击启用
3. 配置短信服务商（推荐使用阿里云短信）：
   - 点击 `Phone` → `Setup`
   - 选择 `Twilio` 或 `阿里云`
   - 填写API密钥和配置
   - 点击 `Save`

### 1.5 创建存储桶

1. 在左侧菜单点击 `Storage`
2. 点击 `New bucket`
3. 创建以下存储桶：
   - **audio**: 存储音频文件
   - **images**: 存储图片文件
4. 对于每个存储桶，设置权限为 `Public`

### 1.6 插入初始数据

1. 在SQL Editor中执行以下SQL：

```sql
-- 创建教师账号
INSERT INTO teachers (id, name, school_id)
VALUES (
  (SELECT id FROM auth.users WHERE email = 'teacher@example.com'),
  '张老师',
  gen_random_uuid()
);

-- 创建示例班级
INSERT INTO classes (teacher_id, name, grade, invite_code)
VALUES (
  (SELECT id FROM teachers WHERE name = '张老师'),
  '大一班',
  '大班',
  'ABC123'
);
```

## 第二步：配置前端项目

### 2.1 创建环境变量文件

在项目根目录创建 `.env` 文件：

```env
VITE_SUPABASE_URL=你的Supabase Project URL
VITE_SUPABASE_ANON_KEY=你的Supabase anon public key
```

### 2.2 测试本地运行

如果您安装了Node.js，可以本地测试：

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

访问 http://localhost:3000 查看效果

## 第三步：部署到Vercel

### 3.1 推送代码到GitHub

1. 在GitHub上创建新仓库 `study-assist`
2. 初始化本地Git仓库：

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/你的用户名/study-assist.git
git push -u origin main
```

### 3.2 在Vercel部署

1. 访问 https://vercel.com/
2. 使用GitHub账号登录
3. 点击 `Add New...` → `Project`
4. 选择你的GitHub仓库 `study-assist`
5. 配置项目设置：
   - **Framework Preset**: `Vite`
   - **Root Directory**: `./`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
6. 添加环境变量：
   - `VITE_SUPABASE_URL`: 你的Supabase Project URL
   - `VITE_SUPABASE_ANON_KEY`: 你的Supabase anon public key
7. 点击 `Deploy`
8. 等待部署完成（约2-3分钟）

### 3.3 访问部署的应用

部署成功后，Vercel会提供一个URL，类似：
- `https://study-assist.vercel.app`

访问这个URL即可使用应用。

## 第四步：配置自定义域名（可选）

### 4.1 在Vercel添加域名

1. 在Vercel项目中，点击 `Settings` → `Domains`
2. 输入你的域名（如: `study-assist.com`）
3. 点击 `Add`

### 4.2 配置DNS

Vercel会显示需要添加的DNS记录：

```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

在你的域名服务商（如阿里云、腾讯云）中添加这些DNS记录。

### 4.3 等待DNS生效

DNS生效通常需要几分钟到几小时不等，可以使用以下工具检查：
- https://www.whatsmydns.net/

## 第五步：测试和验证

### 5.1 测试学生端

1. 访问学生端：`https://你的域名/student`
2. 测试登录功能
3. 测试练习功能
4. 测试结果展示

### 5.2 测试教师端

1. 访问教师端：`https://你的域名/teacher`
2. 使用教师账号登录
3. 测试班级管理
4. 测试题库管理
5. 测试作业发布
6. 测试学情分析

### 5.3 测试跨设备访问

- 在手机浏览器中访问
- 在平板电脑中访问
- 在不同浏览器中测试

## 常见问题

### Q1: 部署后页面空白？

**A**: 检查以下几点：
1. 环境变量是否正确配置
2. 浏览器控制台是否有错误信息
3. Supabase项目是否正常运行

### Q2: 登录失败？

**A**: 检查以下几点：
1. Supabase认证是否正确配置
2. 短信服务商是否正确配置
3. 手机号格式是否正确

### Q3: 图片/音频无法加载？

**A**: 检查以下几点：
1. Supabase存储桶是否设置为Public
2. 文件是否正确上传
3. URL是否正确

### Q4: 如何更新应用？

**A**: 
1. 修改代码后提交到GitHub
2. Vercel会自动检测到更新并重新部署
3. 部署完成后自动生效

### Q5: 如何备份数据？

**A**: 
1. 在Supabase中，点击 `Database` → `Backups`
2. 可以手动创建备份
3. 免费版自动保留7天备份

## 成本估算

### Vercel（前端托管）
- **免费版**: 
  - 100GB带宽/月
  - 无限项目
  - 自动HTTPS
  - 全球CDN

### Supabase（后端服务）
- **免费版**:
  - 500MB数据库存储
  - 1GB文件存储
  - 2GB带宽/月
  - 50,000次API调用/月

**总成本**: 完全免费！

## 性能优化建议

### 1. 图片优化
- 使用WebP格式
- 压缩图片大小
- 使用CDN加速

### 2. 音频优化
- 使用MP3格式
- 压缩音频文件
- 控制音频时长

### 3. 代码优化
- 启用代码分割
- 使用懒加载
- 压缩资源文件

## 安全建议

### 1. 保护敏感信息
- 不要将 `.env` 文件提交到Git
- 使用环境变量存储密钥
- 定期更换密钥

### 2. 数据安全
- 启用数据库备份
- 设置合理的权限
- 定期审查访问日志

### 3. HTTPS
- Vercel自动提供HTTPS
- 确保所有API调用使用HTTPS

## 监控和维护

### 1. 监控工具
- Vercel Analytics: 监控网站性能
- Supabase Logs: 查看API调用日志
- Google Analytics: 用户行为分析

### 2. 定期维护
- 每月检查数据库大小
- 定期清理无用文件
- 更新依赖包版本

## 下一步

部署完成后，您可以：

1. **添加更多题目**: 在题库管理中添加更多单词
2. **创建更多班级**: 在班级管理中创建新班级
3. **发布作业**: 定期发布作业给学生
4. **分析学情**: 查看学生的学习情况

## 技术支持

如果遇到问题，可以：

1. 查看 [Vercel文档](https://vercel.com/docs)
2. 查看 [Supabase文档](https://supabase.com/docs)
3. 查看 [Vue文档](https://vuejs.org/)
4. 在GitHub上提交Issue

## 总结

恭喜！您已经成功部署了"幼儿园英语学习助手"应用。现在您可以：

✅ 学生可以通过手机访问应用进行学习
✅ 教师可以通过PC端管理班级和作业
✅ 所有数据都安全地存储在云端
✅ 完全免费，无需维护服务器

祝您使用愉快！
