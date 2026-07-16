# 密码策略约定

所有新 Laravel 项目(含本地后台登录)须实现密码策略。

## 要求

- **复杂度**:最小长度(默认 8,可配)、大小写+数字+符号(见 `App\Rules\MeetsComplexity`)。
- **密码历史**:禁止复用最近 N 条(默认 8,`password_histories` 表 + UserObserver 记录)。
- **登录锁定**:连续失败达阈值锁定(默认 5 次 / 30 分钟,`failed_login_attempts` + `locked_until`)。
- **服务台重置强制改密**:`admin:password-reset` 重置后 `password_changed_at=null`,首登强制改密。
- **首登/强制改密**:`password.change.required` 中间件拦截未改密用户。

## 实现约定

- `users` 表加列:`password_changed_at`、`failed_login_attempts`、`locked_until`、`active_session_id`。
- `password_histories` 表:`user_id` + `password`。
- `App\Observers\UserObserver`:created/updated(password 变更)写历史 + 裁剪保留 N 条。
- `config/password-policy.php`:`min_length` / `history_count` / `lockout_threshold` / `lockout_minutes`。
- 生产环境本地登录禁用(走 SSO),`AdminDriver` 强制。
