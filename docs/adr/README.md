# Architecture Decision Records (ADR)

本目录记录项目中具有架构意义的决策。每条 ADR 一个编号文件,采用 [Michael Nygard 的 ADR 四段式](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions):Status(状态)/ Context(背景)/ Decision(决策)/ Consequences(后果)。

## 约定

- **只追加(append-only):** 已 Accepted 的 ADR 不再修改其决策内容;若决策被推翻或变更,新写一条 ADR 并在旧 ADR 顶部 Status 改为 `Superseded by ADR-XXXX`,附新链接。
- **编号递增:** `0001-`、`0002-`…,零填充至 4 位。
- **一份决策一个文件:** 文件名 `NNNN-kebab-case-title.md`。
- **不替代 spec:** ADR 记录「为什么这么定」;`specs/` 记录「系统该怎样」。两者互补,ADR 中以「关联规格」指向具体 spec 章节。

## 如何写一条新 ADR

1. 复制 `0000-template.md` 为 `NNNN-短标题.md`(编号紧接现有最大值,首个为 `0001-`)。
2. 填四段:Status(默认 `Accepted`)、Context(背景与备选方案)、Decision(决策与理由)、Consequences(正负面后果)。
3. 在下方索引表追加一行。
4. 若推翻旧决策,把旧 ADR 的 Status 改为 `Superseded by ADR-NNNN` 并附链接。

## 索引

| 编号 | 标题 | 状态 | 日期 |
|---|---|---|---|
| _(空——新项目尚无 ADR,按上方步骤写第一条)_ | | | |
