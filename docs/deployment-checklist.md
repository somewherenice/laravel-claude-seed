# 部署 Checklist(Laravel)

## 部署前

- [ ] `composer install --no-dev --optimize-autoloader`(生产无 dev 依赖)
- [ ] `npm run build` 前端产物已生成
- [ ] `php artisan migrate --force` 迁移已跑(生产需 `--force`)
- [ ] `php artisan config:cache` / `route:cache` / `view:cache` 缓存已构建
- [ ] `php artisan event:cache` 事件缓存(生产)
- [ ] `php artisan queue:restart` 重启 worker(代码变了)
- [ ] `.env` 生产值:`APP_ENV=production`、`APP_DEBUG=false`、`APP_KEY` 已设
- [ ] 队列 / 调度 worker 已配(supervisor / Laravel Cloud)
- [ ] 定时任务 cron 已配(`schedule:run`)
- [ ] 备份:DB 已备份,可回滚
- [ ] 主机 NTP/SNTP 时间同步已启用(审计日志时间戳与其他系统一致)

## 部署后验证

- [ ] 健康检查端点 200
- [ ] 关键路径冒烟(登录、主流程)
- [ ] 日志无新增 error
- [ ] 队列在处理、调度在跑

## 回滚

- [ ] 代码回上一版本(git revert 或重新部署旧版)
- [ ] 迁移回滚:`php artisan migrate:rollback`(仅当迁移可逆;不可逆迁移需手写回滚 SQL)
- [ ] 缓存清理:`php artisan optimize:clear`
- [ ] 验证回滚后状态

## Laravel Cloud 要点

- 部署命令在 Cloud 控制台配,上述 artisan 命令按需纳入 deploy hook
- 环境变量在 Cloud 控制台设,不进 `.env` 文件
- 队列 / 调度由 Cloud 托管,无需自配 supervisor / cron
- 零停机部署:新实例就绪后才切流量;**破坏性迁移需向前兼容**——先部署兼容代码,再跑破坏性迁移,否则回滚时旧代码读不了新 schema
