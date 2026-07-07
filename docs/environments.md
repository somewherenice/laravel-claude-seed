# 多环境约定

> local / staging / production 三环境,配置隔离,互不污染。

## 各环境定位

| 环境 | 目的 | 数据 | 调试工具 |
|---|---|---|---|
| local | 开发调试 | SQLite / 本地 DB,可随意重置 | Telescope + Debugbar 全开 |
| staging | 预发布验证,贴近生产 | 类生产的 DB,脱敏或独立数据集 | Telescope 开,Debugbar 关 |
| production | 线上 | 真实数据 | 全关,只留日志/监控 |

## 配置来源

- **`.env` 不入 git**(Laravel 默认 gitignore)。local 直接编辑 `.env`。
- **staging / production 不用 `.env` 文件**:环境变量在 Laravel Cloud 控制台或服务器 secrets 注入,避免密钥落盘。
- **`APP_KEY` 各环境独立**,不共用——换 key 会失效所有加密 cookie / session。
- **第三方 API key 各环境独立**:测试 key 不进生产,生产 key 不进开发机。

## DB

- local:SQLite(`database/database.sqlite`)或本地 MySQL,随意 `migrate:fresh`。
- staging / production:MySQL / PostgreSQL,禁止 `migrate:fresh`(丢数据),只 `migrate`。
- 生产 DB 连接信息走环境变量,不进配置文件硬编码。

## 缓存与队列

| 项 | local | production |
|---|---|---|
| `config:cache` / `route:cache` | 不跑(改配置要重启才生效,碍事) | 部署时跑(见 `deployment-checklist.md`) |
| 队列连接 | `sync`(同步,出错立即看到) | `redis` / `database` |
| 缓存存储 | `array` / `file` | `redis` / `memcached` |

## 不该有的

- `APP_DEBUG=true` 进 staging / production
- 生产 API key 出现在 local `.env`(泄露风险)
- 三环境共用一个 DB
- 生产环境跑 `migrate:fresh` / `db:seed`(除非灾难恢复且有备份)
