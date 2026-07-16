# 审计日志约定(等保 2.0 贴出的需求)

所有新 Laravel 项目须实现结构化审计日志,覆盖用户与管理员活动。

## 需求(贴出的合规清单)

1. 用户 + 管理员活动审计
2. 成功登录 / 登出 / 失败登录
3. 特权用户(管理员)活动
4. 日志条目含:Date/Time、Initiating Process、Process owner、Description
5. 数据访问查询活动(页面浏览)
6. 数据增、改、删
7. 时间戳经 NTP/SNTP 与其他系统同步
8. 审计日志可导出供进一步处理

> 留存期 ≥6 个月、防删除/修改/覆盖(防篡改)视项目合规要求追加;基线只做上述 8 条。

## 实现约定(Log 方案,不建 DB 表、不加依赖)

- **存储**:`config/logging.php` 加独立 `audit` 通道(daily + `Monolog\Formatter\JsonFormatter`),JSON 每行一条。
- **AuditLogger 封装**:`app/Support/AuditLogger::record($eventType, $description, $success, $extra)` 统一装配字段,try/catch 不阻断业务。
- **字段映射**:Date/Time=`datetime`;Initiating Process=`route`+`method`+`ip`+`user_agent`(控制台=`cli_user`);Process owner=`user_id`+`user_name`+`guard`;Description=`message`+`description`;登录方式=`login_method`(guard 映射,web=local/sso=sso)。
- **捕获点**:
  - auth 事件监听器(`Login`/`Failed`/`Logout`)**靠 Laravel 自动事件发现注册**(handle 方法类型提示),**不手动 `Event::listen`**;Failed 记 attempted email 不记密码。
  - 锁定/SSO 拒绝/重放等未触发 auth 事件的分支,在控制器/监听器显式记。
  - 中间件(别名 `audit.access`,挂 admin 路由组,`admin.auth` 之后)用 try/finally 记所有 admin HTTP 请求(全方法)+ 响应状态,覆盖页面浏览/数据动作/失败尝试。
  - 控制台特权命令显式记(记 `cli_user`、`login_method=null`)。
- **导出**:`php artisan audit:export [--from|--to|--type|--format=csv|json|--output]` 扫 audit 日志文件输出。
- **NTP**:应用 UTC,主机 NTP/SNTP 同步写部署清单(应用层不实现 NTP)。

## 踩坑(实战,必读)

- **audit 通道 `level` 固定 `info`,不用 `env('LOG_LEVEL')`**:审计写 `info` 级,若通道 level 跟 `LOG_LEVEL` 走,生产把 `LOG_LEVEL` 提到 `warning`/`error` 时 audit 的 info 日志被过滤丢失。审计日志必须无视 `LOG_LEVEL` 始终写入。
- **auth 监听器靠自动发现,不手动注册**:Laravel 12 默认开启事件自动发现(扫描 `app/Listeners` 的 `handle` 类型提示)。若又在 `AppServiceProvider` 手动 `Event::listen(Login::class, AuditAuthLogin::class)`,同一事件注册两次 -> 每次登录写两条审计记录(双记)。正解:只放监听器类,不手动注册。
- **中间件异常状态码提取**:`try/finally` 捕获下游异常记 `status` 时:
  - `ValidationException`(422)用 `$e->status` 属性,**不是** `getStatusCode()`(它没有)。
  - `AuthorizationException`(403)**无** `getStatusCode()`,固定返回 403(`instanceof` 判断)。
  - `HttpException` 用 `getStatusCode()`。
  - 顺序:先 `ValidationException` -> `AuthorizationException` -> `getStatusCode()` fallback。
- **ValidationException 对非 JSON 请求不进中间件 catch**:Laravel 把 `ValidationException` render 成 302 redirect(带 session errors)在中间件之前,异常不传到中间件 `catch (Throwable)`,走正常返回路径拿到 302(被判 success)。靠 `RedirectResponse + session->has('errors')` 识别为 422 失败,强制 `status=422, success=false`。

## 不做(YAGNI)

- 不建 DB 审计表(除非要防篡改/精确留存)。
- 不做数据变更前后值(before/after)--需求只要求「捕获」不要求「记值」。
- 不加 spatie/activitylog 等依赖。
