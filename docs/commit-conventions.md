# Commit 与分支约定

## Commit Message

格式:`<type>(<scope>): <subject>`,subject 祈使句、中文、≤50 字。

**type:**
- `feat` 新功能
- `fix` 修 bug
- `refactor` 重构(不改行为)
- `perf` 性能优化
- `test` 测试
- `docs` 文档
- `chore` 构建 / 依赖 / 杂项
- `style` 格式(Pint 已自动化,少用)

**scope**:模块名(`posts`、`auth`、`db`),可省。

**body**(可选):为什么改、权衡,每行 ≤72 字。
**footer**(可选):Breaking Changes、关联 issue / ADR。

例子:
```
feat(posts): 定时发布到期通知
fix(auth): 登录限流按 IP 而非用户名,防枚举
refactor(posts): 可见性改查询时判定,见 ADR-0001
```

## 分支策略

- `main` —— 可发布稳定分支
- `feature/<短描述>` —— 新功能
- `fix/<短描述>` —— bug 修复
- `hotfix/<短描述>` —— 生产紧急修复(从 `main` 拉,合回 `main`)
- `release/<版本>` —— 发布准备(可选)

## PR 模板

PR 描述含:
- **变更摘要**(1-3 行)
- **关联**:issue / ADR / spec 章节
- **测试**:跑了哪些、结果
- **风险**:可能副作用、回滚方式
- **检查**:迁移已跑、依赖已装、文档已更新
