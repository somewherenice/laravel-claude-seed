# 翻车历史档案(Lessons Learned)

AI 设计/编码翻车案例库。**会话开始应先读本文件载入上下文**,设计/编码时对照防坑。新增教训按下方模板追加于此,勿往 `CLAUDE.md` 堆砌(保持 `CLAUDE.md` 只放精简判据)。

## 模板

### <一句话标题>(YYYY-MM-DD)
- **场景**:做了什么任务
- **坑**:哪里假设错了 / 没读代码
- **根因**:为什么会犯
- **判据/防范**:下次怎么避免(可执行,与 `CLAUDE.md` 判据呼应)

---

## 设计阶段漏读代码:RBAC 多 guard(2026-07-14)

- **场景**:设计后台 RBAC,在 brainstorming 鉴权流程那节假设 `Gate::before` 能拿到当前登录用户。
- **坑**:没读 `config/auth.php` 就下笔。实际本项目生产用 `sso` guard,而 Laravel `Gate` 默认走默认 guard(`web`)-> 取到 null,整个 RBAC 在生产环境失效。直到用户要求自审、读了 `auth.php` / `AdminDriver` / `Saml2SignedIn` 才发现。
- **根因**:把"框架一般情况(Gate 取默认 guard 用户)"当成"本项目实际情况(后台用 sso guard)";设计阶段没读现有架构代码就静默假设。
- **判据/防范**:设计每节前自问"这节有没有没读代码就断言能工作的点";每个"我假设 X"要么读代码 / `search-docs` / `database-schema` 证实,要么在设计里标"待验证"。高发区:鉴权/多 guard、中间件链与顺序、Eloquent morph、已有 listener/命令/测试认证方式。正解:后台中间件内 `Auth::shouldUse(AdminDriver::guard())` 切默认 guard,Gate 才能取到后台用户。
