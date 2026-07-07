# Code Review Checklist

> PR 合并前 reviewer 用。不重复 skill/agent 已覆盖的细节,指向它们。
> 自查也用这份——提 PR 前先过一遍,省一轮 review 往返。

## 正确性

- [ ] 逻辑实现了 PR 描述的目标,边界(空集合 / null / 越界)有处理
- [ ] 没引入回归:相关测试已跑,`php artisan test --compact` 绿
- [ ] 异常路径有处理(不吞异常、不裸 `catch (Exception $e) {}`)

## 安全

- [ ] 权限/认证到位:Policy 覆盖所有 mutation 路由,没有越权
- [ ] 无 mass assignment 漏洞:`$fillable` 限定,`$request->all()` 没直接灌 `update`
- [ ] 无 SQL 注入:无拼接的 `DB::raw` / `whereRaw` 用绑定
- [ ] 敏感数据不进日志/响应/Telescope(见 `observability.md`)
- [ ] 跑过 `laravel-security-audit` skill(7 维度 grep/artisan)

## 性能

- [ ] 无 N+1:跑过 `n1-reviewer` agent 或确认 `with()`/`load()` 到位
- [ ] 无循环里查 DB / 发 HTTP
- [ ] 大结果集分页或 chunk,不全量加载
- [ ] 该缓存的缓存了(`Cache::remember`,注意失效)

## 测试

- [ ] 覆盖 happy path + 失败路径 + 关键边界
- [ ] 用 factory,不手动 `new Model([...])` 塞假数据
- [ ] 测试隔离:不依赖其他测试的副作用(RefreshDatabase / 事务)

## 可维护

- [ ] 命名表意(`isPublishedFor`,非 `check()`);符合 `laravel-best-practices` skill
- [ ] 无死代码 / 注释掉的代码 / `dd()` 残留
- [ ] 公共逻辑提取,未引入一次性抽象(Karpathy:单次使用不抽象)

## 数据库 / 迁移

- [ ] 迁移可逆(`down()` 能回滚);不可逆的有注释说明
- [ ] 破坏性迁移向前兼容(见 `deployment-checklist.md`):先部署兼容代码,再跑破坏性迁移
- [ ] 索引补齐(新查询模式有对应索引)

## 文档

- [ ] 架构决策有 ADR(`docs/adr/`)
- [ ] PR 描述含变更摘要 / 关联 issue / 测试 / 风险(见 `commit-conventions.md` PR 模板)
- [ ] 影响行为变更的,`specs/` 或 README 已更新
