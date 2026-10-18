# 账清 · 宿舍零食记账

## 部署（全程浏览器，无需本地装任何开发工具）

### 一次性准备
1. Supabase：注册 → SQL Editor 执行 `supabase_schema.sql`（末尾含 2026 必须的 grant 授权）→ 左侧 Connect 复制 Project URL → Settings → API Keys 复制 Publishable key（sb_publishable_ 开头）
2. 用记事本打开 `lib/supabase_client.dart`，把两个占位值换成自己的
3. GitHub：注册 → New repository（名字随意，Public）→ 上传本仓库全部文件

### 构建 APK（安卓）
Actions 标签页等 **Build APK** 变绿 → 点进运行 → Artifacts → 下载 app-release → 解压得 APK

### 部署网页版（iOS / 备用入口）
仓库 Settings → Pages → Source 选 **GitHub Actions** → 等 **Deploy Web** 变绿
→ 访问 https://你的用户名.github.io/仓库名/
iPhone：Safari 打开 → 分享 → 添加到主屏幕
