# 如何在新 Laravel 项目复用这套 Claude Code 配置

> 本文件是「Laravel 种子」(② 层)的使用说明。三个配置层各自独立、互不依赖:
>
> - **① 个人通用层** `~/.claude/CLAUDE.md` + `~/.claude/agents/` + `~/.claude/skills/` + `~/.claude/settings.json`
>   语言无关的工作风格(Karpathy 准则、中文沟通、doc-generator agent 等)。**所有项目自动生效**,无需任何操作。
> - **② Laravel 种子层** `~/claude-seeds/laravel/`(就是本文件所在目录)
>   Laravel 通用配置(Boost 规范、PHP/Pint/PHPUnit 约定、laravel-boost MCP、n1-reviewer、pint hook、权限白名单)。每个新 Laravel 项目复制一次。
> - **③ 项目专属层** 新项目仓库内的 `CLAUDE.md` 项目概述段 + `specs/` + `docs/` + 代码 + 项目记忆。手写,只属于该项目。

---

## 新项目工作流(照抄即可)

```bash
# 1. 建新 Laravel 项目
laravel new my-app && cd my-app

# 2. 拉入 ② 层 Laravel 种子配置(只补不覆盖,排除 .git)
rsync -a --ignore-existing --exclude='.git' ~/claude-seeds/laravel/ .
# --ignore-existing:新项目已有的文件(README.md / .gitignore 等)不覆盖,只补种子独有的
# --exclude='.git':必须,否则种子的 commits/objects 混进新项目 git,状态会乱

# 2b. settings.local.json 是本地文件,种子以 .example 模板形式分发,改名生效:
mv .claude/settings.local.json.example .claude/settings.local.json

# 3. 安装 laravel-boost(.mcp.json 已就位,但要装包才能跑 boost:mcp)
composer require laravel/boost --dev
php artisan boost:install                     # 生成 boost.json、注入 skills 等(按提示)

# 4. 在新项目的 CLAUDE.md 顶部补 ③ 层:项目概述
#    打开 CLAUDE.md,在 <laravel-boost-guidelines> 块之前/之后加一段:
#    项目名、目录结构、当前状态、本项目特有约定。
#    (种子 CLAUDE.md 顶部已有提示语,照做即可)

# 5. 进 Claude Code
claude
# ① 层全局自动生效;② 层已在仓库;③ 层你刚写好。开干,不用再沟通任何约定。
```

---

## 各文件作用(② 层清单)

| 文件 | 作用 | 是否项目级必需 |
|------|------|----------------|
| `CLAUDE.md` | Laravel 通用指令(Boost guidelines 全文)。顶部留了填 ③ 层项目概述的提示 | 是 |
| `.mcp.json` | 注册 `laravel-boost` MCP(跑 `php artisan boost:mcp`)。**必须项目级**,因为它绑定该项目的 artisan | 是 |
| `boost.json` | laravel-boost 配置(启用的 skills 等) | 是 |
| `AGENTS.md` | 给子 agent 的项目说明 | 可选 |
| `.claude/settings.local.json.example` | 权限白名单(php/composer/pint/npm/git allow,rm -rf/.env deny)+ pint hook 注册 + MCP 启用。**本地文件,种子以 .example 模板分发**(全局 gitignore 会忽略 `settings.local.json` 本体)。复制进项目后 `mv` 成 `.claude/settings.local.json` | 是 |
| `.claude/hooks/pint-postedit.sh` | PostToolUse hook:每次 Edit/Write .php 后自动跑 Pint 格式化。已用 `$CLAUDE_PROJECT_DIR` 做通用化,跨项目可用 | 是 |
| `.claude/agents/n1-reviewer.md` | N+1 查询审查 agent | 是 |
| `.claude/skills/laravel-best-practices/` | Laravel 最佳实践 skill(含 20 条 rules) | 是 |
| `.claude/skills/tailwindcss-development/` | Tailwind 开发 skill | 是 |
| `.claude/skills/laravel-security-audit/` | 安全审计 checklist skill(7 维度 grep/artisan 命令,审计时用;与 best-practices 的编码时安全规则互补) | 是 |
| `docs/adr/` (README + 0000-template) | ADR 四段式决策记录模板与约定(append-only / 编号 / 命名) | 可选 |
| `docs/commit-conventions.md` | Commit message 规范 + 分支策略 + PR 模板 | 是 |
| `docs/deployment-checklist.md` | 部署前 / 部署后 / 回滚 checklist(Laravel Cloud) | 是 |
| `docs/observability.md` | 结构化日志 / 错误上报 / 监控指标约定 | 是 |
| `docs/ci-cd.md` | CI 策略:跑什么 / 门禁 / 本地复现 | 是 |
| `docs/ci-templates/github-actions.yml` | GitHub Actions 模板(PHPUnit + Pint + composer audit),复制到 `.github/workflows/` 生效 | 是 |
| `docs/code-review.md` | PR review / 自查 checklist,指向 n1-reviewer / security-audit / best-practices | 是 |
| `docs/environments.md` | local / staging / production 配置隔离约定 | 是 |
| `docs/backup-recovery.md` | 备份对象 / 频率 / 恢复演练 / 灾备按需 | 是 |

---

## 常见问题

**Q: `settings.local.json` 是本地文件,要不要进 git?**
不要。它含本地权限/hook 设置,Claude Code 默认把它放 `.gitignore`。新项目 `cp` 进来后保持本地即可。团队共享权限用 `.claude/settings.json`(入 git),个人偏好用 `settings.local.json`。

**Q: hook 不生效?**
确认两点:① 脚本可执行(`chmod +x .claude/hooks/pint-postedit.sh`,种子已设);② `settings.local.json` 里 hook 命令是相对路径 `bash .claude/hooks/pint-postedit.sh`(已修好,不要改回绝对路径)。Claude Code 执行 hook 时 cwd 是项目根,相对路径能找到。

**Q: `laravel-boost` MCP 报错连不上?**
先 `composer require laravel/boost --dev`,再 `php artisan boost:install`。MCP 通过 `php artisan boost:mcp` 启动,缺包就起不来。

**Q: 想升级种子里的约定(比如 Pint 规则变了)?**
直接改 `~/claude-seeds/laravel/` 里的文件。建议把这个目录 `git init` 托管,改动有版本记录,多机同步也方便:
```bash
cd ~/claude-seeds/laravel && git init && git add -A && git commit -m "init laravel seed"
```

**Q: 项目记忆(memory)会带过来吗?**
不会。记忆按项目路径隔离(`~/.claude/projects/<项目路径>/memory/`)。所以「我是谁、我怎么工作」这类个人事实写进 ① 层 `~/.claude/CLAUDE.md`(全局),而不是项目记忆。项目记忆只放该项目的领域知识。

**Q: 新项目要 specs 文档(PRD/架构/API/SPEC)怎么办?**
直接跑 `doc-generator` agent(① 层全局自带,在 `~/.claude/agents/`)。它读项目代码,生成 `specs/PRD.md`、`specs/ARCHITECTURE.md`、`specs/SPEC.md`、`specs/API.md` + `docs/UML.md` 全套。别手动建空文件,也别把 specs 模板塞进种子——内容是项目专属的,骨架由 agent 按实际代码动态生成,塞模板反而会过时。

**Q: 下个项目不是 Laravel 怎么办?**
① 层照常生效。② 层不用(它是 Laravel 专属)。可仿照这个种子,另建 `~/claude-seeds/<其他栈>/` 做对应栈的种子。

---

## 一句话速查

> 新 Laravel 项目:`laravel new` → `rsync -a --ignore-existing --exclude='.git' ~/claude-seeds/laravel/ .` → `mv .claude/settings.local.json.example .claude/settings.local.json` → `composer require laravel/boost --dev` → `php artisan boost:install` → 补 `CLAUDE.md` 项目概述 → `claude`。

---

## 维护约定(项目持续开发时,边做边补,别等完工再整理)

本项目这套配置其实是**两份**:
- `~/claude-seeds/laravel/` —— 种子的「源」,git 托管,给未来新项目用
- 当前项目仓库里的同款文件 —— live 副本,真正在生效

**改通用约定时两边都要改**,否则未来新项目拿到的种子是旧的。判断一次改动属于哪一层:

| 改动 | 同步到 | 举例 |
|------|--------|------|
| Laravel 通用约定 / skill 规则 / agent / hook 逻辑 | **种子**(改完 commit) | 给 pint hook 加新逻辑、改 laravel-best-practices 规则、新建通用 agent |
| 语言无关的个人偏好 / 跨语言 agent | **用户级** `~/.claude/` | 新的工作风格准则、doc-generator 之类通用 agent |
| 本项目业务逻辑 / 模型 / 路由 / specs / 项目概述 | **只本项目仓库** | Post 模型、业务规则、本项目特有约定 |

工作模式:**Claude 主动判断 + 用户偶尔提醒**。
- Claude 改完某个明显属于 Laravel 通用层的约定后,主动提一句「这个建议同步到种子,要我现在同步吗?」,用户点头再动。
- 用户改完通用约定后说一句「同步到种子」,Claude 负责 `cp` 过去 + git commit。
- 业务代码绝不往种子塞。

**Why:** 边做边补成本几乎为零(刚写完代码最清楚什么能复用);一次性整理容易忘、容易漏、分不清通用 vs 专属。

