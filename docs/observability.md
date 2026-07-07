# 可观测性约定

## 日志

- **结构化**:`Log::info('post published', ['post_id' => $post->id, 'user_id' => $user->id]);` —— context 用键值,不拼字符串。
- **级别**:`debug`(开发)/ `info`(关键业务事件)/ `warning`(可恢复异常)/ `error`(需介入)。
- **不记敏感**:`password` / `api_key` / `token` / 卡号一律不进日志。审查时 grep `Log::.*\$request->all`。
- **通道**:生产 `error` 以上进独立通道或告警系统,不混 default。
- **工具**:Pail 看本地实时日志;生产用日志聚合。

## 错误上报

- 异常通过 `bootstrap/app.php` 的 `withExceptions` 集中处理。
- 生产 `APP_DEBUG=false`,错误页不泄露栈。API 路由强制 JSON 响应。
- 可报告异常入日志 / 告警;高频异常 `dontReport` 或限流防日志洪泛。
- 关键异常接告警(Sentry / 邮件 / Slack),不只进日志文件。

## 监控指标(至少)

- **应用**:响应时间、错误率、吞吐(慢请求 > 1s 标记)
- **队列**:积压数、失败任务数、处理时长
- **调度**:任务是否按时跑、是否超时
- **DB**:慢查询、连接数
- **业务**:关键转化(发布、登录、核对完成)计数

## 开发工具(仅非生产)

- Telescope:本地 / staging 调试,生产关闭
- Debugbar:仅本地
- `config:show` / `route:list` / `db:monitor` 日常排查

## 不该有的

- `dd()` / `dump()` 进生产代码(部署前清)
- `APP_DEBUG=true` 进生产
- 敏感数据进日志 / 错误页 / Telescope
