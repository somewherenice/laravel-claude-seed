# ① 层全局参考(脱敏副本)

本目录是 `~/.claude/` 全局层的脱敏副本,供参考借鉴。实际部署时这些文件放在用户级 `~/.claude/` 下,所有项目自动生效,无需复制到每个项目仓库。

## 文件

- `CLAUDE.md` —— 放 `~/.claude/CLAUDE.md`。语言无关的个人工作风格准则(Karpathy 四条 + 中文沟通)。
- `doc-generator.md` —— 放 `~/.claude/agents/doc-generator.md`。任意栈生成 specs 全套文档的 agent。

## 未包含(需各自管理)

- `~/.claude/settings.json` —— 含 API token / endpoint 等凭证,不入公开仓库。
- `~/.claude/settings.local.json` —— 跨项目积累的权限白名单,带个人痕迹,不入公开仓库。

## 怎么用

复制这两个文件到自己的 `~/.claude/` 对应位置,改成本人偏好的沟通语言和准则,即全局生效。
