# Japanese Learning - Backend API

Laravel API 後端服務，提供日語學習網站的 RESTful API。

## 技術棧

- **框架**: Laravel 12
- **PHP**: 8.4
- **認證**: Laravel Sanctum (API Token)
- **OAuth**: Laravel Socialite (Google Login)
- **數據庫**: MySQL 8.0 / PostgreSQL
- **緩存**: Redis

## 功能

- ✅ 用戶註冊 / 登入 / 登出
- ✅ Google OAuth 2.0 登入
- ✅ API Token 認證
- 🚧 日語詞彙管理 (計劃中)
- 🚧 學習進度追蹤 (計劃中)

## 本地開發

### 使用 Laravel Sail (Docker)

```bash
# 安裝依賴
composer install

# 啟動容器
./vendor/bin/sail up -d

# 運行遷移
./vendor/bin/sail artisan migrate

# 生成應用密鑰
./vendor/bin/sail artisan key:generate
```

訪問: http://localhost

### 環境變量

複製 `.env.example` 到 `.env` 並配置：

```env
APP_NAME="Japanese Learning API"
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=sail
DB_PASSWORD=password

# Google OAuth
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URI=http://localhost/api/auth/google/callback

# Frontend URL (CORS)
FRONTEND_URL=http://localhost:5173
```

## API 端點

### 認證

- `POST /api/register` - 用戶註冊
- `POST /api/login` - 用戶登入
- `POST /api/logout` - 用戶登出 (需要認證)
- `GET /api/me` - 獲取當前用戶 (需要認證)

### Google OAuth

- `GET /api/auth/google` - 重定向到 Google 登入
- `GET /api/auth/google/callback` - Google OAuth 回調
- `POST /api/auth/google` - 前端 Google Token 登入

### 健康檢查

- `GET /health` - 健康檢查端點

## 生產部署

### Docker 映像

映像名稱: `docker.io/<username>/project-api`

標籤:
- `latest` - 最新穩定版本
- `main-<commit-sha>` - 特定提交版本
- `v1.0.0` - 語義化版本

### 構建映像

```bash
docker build -t project-api:local .
```

### 運行容器

```bash
docker run -d \
  -p 80:80 \
  -e APP_KEY=your-app-key \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=your-db-name \
  -e DB_USERNAME=your-db-user \
  -e DB_PASSWORD=your-db-password \
  project-api:local
```

## CI/CD

GitHub Actions 自動化流程：

- ✅ 代碼推送到 `main` 分支自動構建
- ✅ 自動推送到 Docker Hub
- ✅ 自動標籤管理
- ✅ 構建緩存優化

### 必要的 GitHub Secrets

- `DOCKER_USERNAME` - Docker Hub 用戶名
- `DOCKER_PASSWORD` - Docker Hub 訪問令牌

## 項目結構

```
api/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       ├── AuthController.php
│   │       └── GoogleAuthController.php
│   └── Models/
│       └── User.php
├── config/
│   ├── cors.php
│   └── sanctum.php
├── docker/
│   ├── nginx.conf
│   ├── default.conf
│   └── supervisord.conf
├── routes/
│   └── api.php
├── Dockerfile
├── .dockerignore
└── composer.json
```

## 相關倉庫

- [Frontend (Vue 3)](https://github.com/<username>/project-frontend)
- [Infrastructure (Helm Charts)](https://github.com/<username>/project-infra)

## 開發計劃

### Phase 1: 基礎功能 ✅
- [x] 用戶認證系統
- [x] Google OAuth 登入
- [x] Docker 容器化
- [x] CI/CD 流程

### Phase 2: 核心功能 🚧
- [ ] 詞彙 CRUD API
- [ ] 學習進度追蹤
- [ ] 測驗系統 API

### Phase 3: 進階功能 📋
- [ ] 背景任務隊列 (Laravel Horizon)
- [ ] 通知系統
- [ ] 數據導出功能

## License

MIT
