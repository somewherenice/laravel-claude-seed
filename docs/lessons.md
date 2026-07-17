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

---

## 跑 doc-generator 前未查 superpowers 已有 spec/plan:差点重复生成(2026-07-17)

- **场景**:用户问"项目有架构图吗",AI ls `specs/`(doc-generator 默认产出路径)发现不存在,判断"全缺 spec/UML",建议并派 doc-generator 从零生成 `specs/` + `docs/UML.md`。
- **坑**:项目实际已有 `docs/superpowers/specs/`(brainstorming 产出的模块设计 spec)+ `docs/superpowers/plans/`(实现 plan),是详尽的模块级设计,比 doc-generator 从代码反推更深。AI 只查了 doc-generator 默认产出路径 `specs/`,没查项目实际存放路径 `docs/superpowers/`;且 commit message 明确"归档 spec/plan"也视而不见。若按原 prompt 跑,`SPEC.md` 会重复发明已有模块设计且更浅。用户拦下指出后才查清。
- **根因**:把"doc-generator 默认产出路径 `specs/`"当成"项目唯一可能的 spec 存放位置",没盘点项目实际文档存量;查文档时只查默认路径不查实际路径,且不看 commit/索引线索。同源"动手前先查证、不静默假设"(呼应 CLAUDE.md 设计验证判据)。
- **判据/防范**:跑 doc-generator / 生成文档前,先查项目已有 spec/plan/文档存量--`find docs -type f`、看 `docs/superpowers/specs|plans/`、看最近 commit message 有无"spec/plan/归档"线索、看 `docs/adr/`。已有产出的模块别让 doc-generator 从零重写:`SPEC.md` 退化为索引页指向 `docs/superpowers/specs/`,doc-generator 只补真空白(PRD/全局 ARCHITECTURE/UML/API)。判据:doc-generator 五个产出逐个问"这个项目是否已有更详尽版本",有则不重写。

---

## 盲信 doc-generator 产出未自审:6 Critical 脑补(2026-07-17)

- **场景**:doc-generator 生成全局文档,subagent 报"从真实代码归纳,不脑补"。主会话抽查文件存在+行数+几个点就准备 commit,用户要求"自审"才派 reviewer。
- **坑**:doc-generator 在架构/UML 文档脑补了 6 个 Critical,全与代码/ADR 冲突:虚构关联表 + Model 关系(实际 JSON 列 + enum)、事件 Subscriber 类(实际分散 listener + 中间件 + 静态调用)、Observer 类(实际 controller 直接 dispatch)、多个类名张冠李戴、guard 名错、`AuthServiceProvider` + `Gate::define`(实际 `AppServiceProvider` 单个 `Gate::before`)。reviewer 逐条 grep 代码证实,主会话再核实全属实,修复后测试全绿。
- **根因**:盲信 subagent"从代码归纳不脑补"的自述,只抽查文件存在+行数就准备入库,没逐条核实技术断言对照代码。doc-generator 从代码归纳时会用框架一般知识填充没读到的细节(类名/表/中间件链/事件名),产出看似合理但与代码不符。
- **判据/防范**:doc-generator / 任何文档生成 subagent 产出后,主会话必须自审--派 reviewer(或亲自)逐条核实技术断言对照代码:类名 grep `class X`、表结构读 migration、中间件链读 `bootstrap/app.php` + routes、guard 读 `config/auth.php`、路由 `route:list`、配置读 `config/`。不符就修,不能盲信 subagent 自述。高发脑补区:关联表/Model 关系(belongsToMany vs JSON 列)、事件 Subscriber/Observer 类名、中间件链顺序、guard 名、`Gate::define` vs `Gate::before`。同源"subagent 产出别盲信"(呼应 CLAUDE.md 设计验证判据 + 查存量判据)。
