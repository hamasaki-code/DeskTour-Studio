# DeskTour Studio

DeskTour Studioは、クリエイター・エンジニアの作業環境（デスク）を共有するRailsアプリです。  
Rails 7 + Tailwind CSS + PostgreSQLで構築されています。

## 実装済みMVP（Phase 1）

- 投稿機能（タイトル・説明・画像・任意アイテムURL）
- 投稿一覧（グリッド表示）/ 投稿詳細
- 検索・タグ絞り込み
- コメント投稿（reCAPTCHA対応）
- いいね機能（Cookieで重複防止）
- 管理画面（投稿・コメントの公開/削除）
- SEO対応（meta/OGP/sitemap/robots）
- 利用規約・プライバシーポリシー・Cookieポリシー
- 広告スロット部分（AdSense有効時のみ表示）
- Amazonリンクのアフィリエイトタグ自動付与

## 技術スタック

- Ruby on Rails 7.2
- Tailwind CSS
- PostgreSQL
- Active Storage（ローカル or S3）

## セットアップ

```bash
gem install bundler:2.6.8
bundle install
bin/rails db:create db:migrate
bin/dev
```

## 主な環境変数

```bash
# Active Storage
ACTIVE_STORAGE_SERVICE=local         # local or amazon
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
AWS_S3_BUCKET=

# Admin
ADMIN_USERNAME=
ADMIN_PASSWORD=

# reCAPTCHA
RECAPTCHA_SITE_KEY=
RECAPTCHA_SECRET_KEY=

# Google AdSense
ADSENSE_ENABLED=false
ADSENSE_CLIENT_ID=
ADSENSE_SLOT_INDEX_BOTTOM=
ADSENSE_SLOT_POST_BODY=
ADSENSE_SLOT_POST_FOOTER=

# Measurement (production only)
GA4_MEASUREMENT_ID=
SEARCH_CONSOLE_VERIFICATION_TOKEN=

# Report moderation
REPORT_AUTO_HIDE_THRESHOLD=3
REPORT_DAILY_LIMIT=5

# Amazon Associate
AMAZON_AFFILIATE_TAG=
```

## 収益化フェーズ

1. `Phase 1`: コンテンツ重視（広告なし）
2. `Phase 2`: Google AdSense審査・導入
3. `Phase 3`: Amazonアソシエイト審査・導入

## ルーティング（主要）

- `/` 投稿一覧
- `/posts/new` 投稿作成
- `/posts/:id` 投稿詳細
- `/privacy-policy` プライバシーポリシー
- `/terms` 利用規約
- `/cookie-policy` Cookieポリシー
- `/sitemap.xml` サイトマップ
- `/admin/posts` 管理画面（Basic認証）
