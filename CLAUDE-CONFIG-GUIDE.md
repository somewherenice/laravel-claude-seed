# 分层 Claude Code 配置方法论(可复用)

> 一套可借鉴的 Claude Code 配置组织方式:把配置按「语言无关 → 栈通用 → 项目专属」分三层,各管一段、互不依赖,新项目按栈复制中间层即可起步。本文讲方法论 + 判断规则 + 一个 Laravel 栈实例,别的栈照搬结构、替换内容。

---

## 0. 为什么分层

Claude Code 的配置散落在 `~/.claude/`(全局)、项目内 `.claude/`、`CLAUDE.md`、`.mcp.json`、`settings.json` 等多处。不分层时常见痛点:

- 同一条约定在每个项目重复手写 → 漂移、过期。
- 个人偏好和栈规范混在一起 → 换栈时全盘重写。
- 项目业务逻辑和通用编码规则混在同一个 CLAUDE.md → 文件膨胀、AI 抓不住重点。

分层后:**改动先判断属于哪一层 → 决定放哪 → 决定是否要同步到其他副本**。判断清楚了,维护成本接近零。

---

## 1. 三层模型

### ① 层 全局 `~/.claude/` —— 语言无关,所有项目自动生效

- **放:** 工作风格准则、跨语言通用 agent、个人偏好(沟通语言、模型选择等)。
- **不放:** 任何语言/框架/栈专属内容(具体编码规范、工具链 hook、栈专属 MCP)。
- **生效方式:** Claude Code 自动加载,无需任何操作。
- **实例:** Karpathy 编码准则(先思考再编码 / 简洁优先 / 外科手术式修改 / 目标驱动执行)、`doc-generator` agent(任意栈生成 specs 全套)。
- **参考副本:** 本仓库 `global-layer/` 提供这两个文件的脱敏副本(`settings.json` 含凭证不入库)。

### ② 层 栈种子 `~/claude-seeds/<stack>/` —— 每栈一份,每项目复制一次

- **放:** 该栈的编码规范、工具链自动化 hook、栈专属 skill/agent、MCP 注册、权限白名单模板、文档模板(ADR 等)。
- **不放:** 项目业务逻辑、项目概述、真实决策记录。
- **生效方式:** 新项目 `cp -rn ~/claude-seeds/<stack>/. .` 拉入;`settings.local.json` 以 `.example` 模板分发(本地文件不入 git)。
- **实例(Laravel):** Boost guidelines、Pint post-edit hook、`laravel-best-practices` / `tailwindcss-development` / `laravel-security-audit` skill、`n1-reviewer` agent、`laravel-boost` MCP、ADR 模板。
- **建议 git 托管** 这个种子目录,改动有版本记录,多机同步方便。

### ③ 层 项目专属 `<project>/` —— 每项目手写,只属于该项目

- **放:** 项目概述(目录结构 / 当前状态 / 特有约定)、业务模型与路由、`specs/`、真实 ADR、项目记忆。
- **不放:** 可跨项目复用的通用约定(那些升 ② 层)。
- **生效方式:** 写在项目 `CLAUDE.md` 顶部 + `specs/` + `docs/` + 项目记忆目录。
- **实例:** 「Posts 有可选 `published_at`,可见性 = 已发布对所有人可见 / 草稿仅作者可见」「登录路由 throttle:login」。

---

## 2. 配置元素清单

每个元素该放哪层:

| 元素 | 作用 | 典型层 | 形态 |
|---|---|---|---|
| `CLAUDE.md` | 准则/指令 | ①②③ 都有,各管各的 | markdown |
| Agent | 派出去的独立子任务执行者 | ①(通用)②(栈专属) | `.claude/agents/<name>.md` |
| Skill | 加载进主对话的知识/规则包 | ②(栈专属)为主 | `.claude/skills/<name>/SKILL.md` + 可选 rules/ |
| Hook | 工具调用前后的自动化脚本 | ②(工具链相关) | `.claude/hooks/*.sh` + settings 注册 |
| MCP server | 外部工具协议(数据库、文档搜索等) | ②(栈专属) | `.mcp.json` |
| `settings.local.json` | 权限白名单 + hook 注册 + MCP 启用 | ② 模板分发,③ 落地 | `.claude/settings.local.json` |
| specs / ADR | 项目文档与决策记录 | ③(真实内容)②(模板) | `specs/`、`docs/adr/` |
| 项目记忆 | 该项目领域知识 | ③ | `~/.claude/projects/<path>/memory/` |

---

## 3. Agent vs Skill:怎么选

这是配置时最常纠结的判断。

**本质:**
- **Skill** = 知识/规则,加载进主对话,边干边参考。无独立上下文,继承主对话全部工具。
- **Agent** = 派出去的独立工人,有隔离上下文 + 收窄工具集 + 只把结论返回主对话。

**四个判断维度:**

| 维度 | 选 Skill | 选 Agent |
|---|---|---|
| 上下文 | 要结合当前对话 / 正在写的代码 | 要读一大堆文件,结论带回即可 |
| 工具集 | 用主对话全部工具即可 | 要收窄(如只读不写) |
| 并行 | 不需要 | 要扇出 / 后台跑 |
| 视角 | 跟着当前判断走 | 要新鲜独立视角 |

**口诀:** 「边干边参考的知识」做 skill,「扫一遍带结论回来」的活做 agent。

**实例对照:**

| 名字 | 类型 | 为什么 |
|---|---|---|
| `laravel-best-practices` | Skill | 编码时持续对照的规则,要结合正在写的代码 |
| `laravel-security-audit` | Skill | 审计 checklist,跟着主对话逐维度跑命令 |
| `tailwindcss-development` | Skill | 写样式时边查边用的模式参考 |
| `n1-reviewer` | Agent | grep + 读多文件交叉分析,隔离上下文避免污染,工具收窄 Read/Glob/Grep |
| `doc-generator` | Agent | 独立读全库产出文档集,产物大、要隔离 |

**frontmatter 区别:**
- Skill:`name` / `description` / `license` / `metadata.author`,正文是规则。自动按 description 触发,或 `/skill-name` 调用。
- Agent:`name` / `description` / `tools`(收窄)/ `model`,正文是系统提示。通过 Agent 工具派发,有独立上下文。

---

## 4. 新项目复用流程(照抄即可)

```bash
# 1. 建新项目
<stack> new my-app && cd my-app

# 2. 拉入 ② 层栈种子(-n 不覆盖已存在的文件)
cp -rn ~/claude-seeds/<stack>/. .

# 2b. settings.local.json 以 .example 分发,改名生效
mv .claude/settings.local.json.example .claude/settings.local.json

# 3. 装该栈的 MCP 依赖(若种子带了 .mcp.json)
# 例 Laravel:composer require laravel/boost --dev && php artisan boost:install

# 4. 在 CLAUDE.md 顶部补 ③ 层项目概述
#    项目名、目录结构、当前状态、特有约定

# 5. 进 Claude Code
claude
# ① 层全局自动生效;② 层已在仓库;③ 层你刚写好。开干。
```

---

## 5. 维护约定:边做边补,别等完工再整理

配置实际是**两份**:
- `~/claude-seeds/<stack>/` —— 种子的「源」,git 托管,给未来新项目用。
- 当前项目仓库里的同款文件 —— live 副本,真正在生效。

**改通用约定时两边都要改**,否则未来新项目拿到的种子是旧的。判断一次改动属于哪一层:

| 改动 | 同步到 | 举例 |
|---|---|---|
| 栈通用约定 / skill 规则 / agent / hook 逻辑 | **种子**(改完 commit)+ 项目 live 副本 | 给 hook 加逻辑、改 skill 规则、新建通用 agent |
| 语言无关的个人偏好 / 跨语言 agent | **① 层** `~/.claude/` | 新工作风格准则、通用 agent |
| 本项目业务逻辑 / 模型 / 路由 / specs / 项目概述 | **只本项目仓库** | 业务规则、特有约定 |

**工作模式:Claude 主动判断 + 用户偶尔提醒。** 业务代码绝不往种子塞。

---

## 6. Claude Code 内置能力(无需配置,直接可用)

搭配置时先了解内置有什么,避免重复造:

- **内置 agents:** `claude`(默认 catch-all)、`Explore`(只读搜索)、`general-purpose`、`Plan`(实现计划)、`statusline-setup`、`claude-code-guide`。自建 agent 覆盖其上。
- **编排/工具能力:** TaskCreate/List(任务管理)、Workflow(多 agent 确定性编排)、EnterPlanMode(计划模式)、EnterWorktree(git worktree 隔离)、Cron(定时任务)、ScheduleWakeup(/loop 自调度)、Skill、AskUserQuestion。
- **MCP:** 装了 `fetch`(抓 URL 取 markdown),栈专属 MCP(如 `laravel-boost`)按需在 `.mcp.json` 注册。

**判断:** 能用内置的就别自建。自建只在「内置不够、且可跨项目复用」时。

### 可选扩展:工程流程闭环(superpowers)

这套配置覆盖「知识层」(准则 / skill / 审计 / 文档生成),但**不含工程流程闭环**——强制 brainstorm → plan → TDD → code-review → systematic-debugging 的串联流程。内置的 Plan agent / TaskCreate 是按需调用,不强制。

[superpowers](https://github.com/obra/superpowers) plugin 补的就是这块。装与不装的判断:

- **学习 / 小项目:不装。** 现在这套够,强流程是负担。
- **商用 / 多步复杂特性:按需装,装在项目级**(不全局)。它生成的 design / plan / review 文档对商用是资产(可追溯 / 审计 / 复盘),不是负担。
- 装的话用 Karpathy「琐碎任务可自行判断」加**规模门槛**:单文件几行走 Karpathy 直接干,多步特性才走 superpowers 全流程;文档产出纳入 git 并定期清理过时的。
- 安装:`/plugin install superpowers@claude-plugins-official`(本仓库已注册该 marketplace)。

---

## 7. 参考:一套 Laravel 栈种子的实际内容

仅作实例,别的栈替换内容、保留结构。

### ① 层 `~/.claude/`

| 文件 | 内容 |
|---|---|
| `CLAUDE.md` | Karpathy 四条 + 中文沟通 |
| `agents/doc-generator.md` | 任意栈生成 specs PRD/ARCHITECTURE/SPEC/API + docs/UML.md |
| `settings.json` | 模型、effort level、API 超时 |
| `settings.local.json` | 跨项目积累的权限白名单 |

### ② 层 `~/claude-seeds/laravel/`

| 文件 | 内容 |
|---|---|
| `CLAUDE.md` | Boost guidelines(Foundational / Boost / PHP / Pint / PHPUnit / Laravel v12) |
| `AGENTS.md` | 给子 agent 的项目说明 |
| `HOW-TO-USE.md` | 本种子使用说明 + 三层模型 + 维护约定 |
| `boost.json` | laravel-boost 配置(启用的 skills 等) |
| `.mcp.json` | 注册 `laravel-boost` MCP |
| `.claude/agents/n1-reviewer.md` | N+1 查询审查 agent |
| `.claude/skills/laravel-best-practices/` | 20 条 rules 的编码 skill |
| `.claude/skills/tailwindcss-development/` | Tailwind v4 开发 skill |
| `.claude/skills/laravel-security-audit/` | 7 维度安全审计 checklist skill |
| `.claude/hooks/pint-postedit.sh` | PostToolUse:改 .php 后自动跑 Pint |
| `.claude/settings.local.json.example` | 权限白名单 + hook 注册 + MCP 启用模板 |
| `docs/adr/` | ADR 四段式模板(README + 0000-template) |

### ③ 层 项目内

| 文件 | 内容 |
|---|---|
| `CLAUDE.md` 顶部 | 项目概述 + 特有约定 |
| `specs/` | PRD / ARCHITECTURE / SPEC / API(由 doc-generator agent 生成) |
| `docs/adr/` | 真实决策记录(0001、0002…) |
| `.claude/` | ② 层的 live 副本 + 项目级 settings.local.json |

---

## 8. 一句话速查

> 改动先判层:语言无关 → ① 全局;栈通用 → ② 种子(两边同步 + commit);项目专属 → ③ 仓库。知识做 skill,扫查做 agent。能用内置的别自建。
