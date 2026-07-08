# Laravel Claude Code 配置种子 · 分层方法论

> **v0.1** · 个人实践快照,持续完善中。借鉴为主,按需裁剪。

一套可复用的 [Claude Code](https://claude.com/claude-code) 配置组织方式:把配置按「语言无关 → 栈通用 → 项目专属」分三层,各管一段、互不依赖,新项目按栈复制中间层即可起步。本仓库以 **Laravel 栈**为实例,方法论适用于任意栈。

## 从哪开始读

| 你的目标 | 看这个 |
|---|---|
| 借鉴分层方法论(任意栈) | [`CLAUDE-CONFIG-GUIDE.md`](CLAUDE-CONFIG-GUIDE.md) |
| 用这套 Laravel 种子建新项目 | [`HOW-TO-USE.md`](HOW-TO-USE.md) |
| 看 ① 层全局配置参考 | [`global-layer/`](global-layer/) |

## 三层模型

- **① 全局** `~/.claude/` —— 语言无关的工作风格(Karpathy 准则)、跨栈通用 agent。所有项目自动生效。
- **② 栈种子** 本仓库 —— Laravel 通用配置(Boost 规范、Pint hook、skill / agent、MCP、权限模板、ADR 模板)。每项目复制一次。
- **③ 项目专属** 项目仓库内 —— 项目概述、业务代码、specs、真实 ADR。手写,只属该项目。

详见 [`CLAUDE-CONFIG-GUIDE.md`](CLAUDE-CONFIG-GUIDE.md) 第 1 节。

## 仓库结构

```
CLAUDE-CONFIG-GUIDE.md   方法论门面(8 节)
HOW-TO-USE.md            Laravel 种子使用说明
CLAUDE.md / AGENTS.md    ② 层 Laravel 准则(Boost guidelines)
boost.json / .mcp.json   ② 层配置(laravel-boost MCP)
.claude/
  agents/n1-reviewer.md          N+1 查询审查 agent
  hooks/pint-postedit.sh         改 .php 自动跑 Pint
  settings.local.json.example    权限白名单 + hook 注册模板
  skills/
    laravel-best-practices/      20 条 rules 编码 skill
    laravel-security-audit/      7 维度安全审计 skill
    tailwindcss-development/     Tailwind v4 skill
docs/adr/                ADR 四段式模板(README + 0000-template)
docs/ci-templates/       GitHub Actions 模板(PHPUnit + Pint + audit)
global-layer/            ① 层脱敏副本(Karpathy CLAUDE.md + doc-generator agent)
```

## 适合谁

- 搭 Laravel 项目、想要一套开箱即用的 Claude Code 配置
- 想给自己的栈(Django / Rails / Node…)搭分层配置,借鉴结构替换内容
- 想了解 Claude Code 的 agents / skills / hooks / MCP 怎么组织

## 不含(需各自管理)

- **凭证**:`~/.claude/settings.json` 的 API token 不入库
- **项目业务代码**:③ 层各自管理,不在种子里
- **工程流程闭环**:强制 code-review / TDD / 调试 / 部署的强流程。本套配置重在「知识层」;若需工程闭环,可选装 [superpowers](https://github.com/obra/superpowers) plugin 补(见 `CLAUDE-CONFIG-GUIDE.md` 第 6 节)

## 状态

v0.1,持续完善。个人实践分享,非权威标准。欢迎借鉴、按需裁剪。

## License

[MIT](LICENSE) © 2026 Wangfuyan
