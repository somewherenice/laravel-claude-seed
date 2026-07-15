# 翻车历史档案(Lessons Learned)

AI 设计/编码翻车案例库。**会话开始对照本文件,把尚无对应 memory feedback 条目的案例转写入项目 memory**(幂等,已有则跳过),之后靠 memory 按场景 recall。新增教训追加于此,勿往 `CLAUDE.md` 堆砌(保持 `CLAUDE.md` 只放精简判据)。

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

---

## 往 CLAUDE.md 加约定前未查工具自带规则:figma 手抄 steering(2026-07-15)

- **场景**:装完 figma plugin,把 figma MCP 资产处理规则 + 生成流程手写进 CLAUDE.md(项目 + 种子通用段)并 push 种子。
- **坑**:没查 plugin 自带什么。实际 figma plugin 自带 `figma-power/steering/implement-design.md` + 8 个 skills,逐条覆盖我写的内容--我写的是其劣化缩写,plugin 升级后手写版还会过时变错。用户要求自审、`ls` 了 plugin 目录才发现。
- **根因**:(1) 顺手多做:用户只问"要不要加项目 CLAUDE.md",我加了项目还主动扩到种子 + push;(2) 凭 README 纸面预写未实战验证,违背"约定从实战翻车来"的传统;(3) 写 CLAUDE.md 段前没先查工具/plugin 自带 skills/steering/rules,默认手抄。
- **判据/防范**:往 CLAUDE.md / 种子加任何工具相关约定前,先查该工具/plugin 是否自带 skills/steering/rules(读 plugin 目录、看 README rules 段)--自带就别手抄(冗余 + 易过时),要用时调 skill;约定优先来自实战踩坑后写本文件,不凭文档预写;用户问 A 只做 A,别顺手扩到 B + push。同源"动手前先查证、不静默假设"(呼应 CLAUDE.md 设计验证判据)。
