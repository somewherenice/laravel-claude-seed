# Laravel Subagent 上下文注入片段

> dispatch superpowers implementer / reviewer subagent 时,把本段 append 到其 prompt。
> subagent 不继承项目 CLAUDE.md,须显式告知 Laravel 规范。本片段是 Boost guidelines 的可注入摘要。

## Laravel 硬约束(本项目)

- 用 `php artisan make:` 建文件(migration/controller/model/request/job/mailable 等),传 `--no-interaction` 及正确 `--options`。通用 PHP 类用 `make:class`。
- Model 用 `casts()` 方法,不用 `$casts` 属性(Laravel 12)。
- URL 一律 named route + `route()`,禁止字符串拼路径。
- 改表前用 `database-schema`(Boost MCP)查现有结构;迁移改列须包含该列所有原属性,否则丢失。
- 不确定的 API 先 `search-docs`(Boost MCP)查版本特定文档,再写;用多个宽泛 query。
- 校验用 FormRequest,不内联 `$request->validate()`;与同类 controller 保持一致。
- 收尾跑 `vendor/bin/pint --dirty --format agent`(不要 `--test`)。
- 测试用 PHPUnit(`php artisan make:test --phpunit`,`--unit` 造单元测试),工厂建模型,覆盖 happy/failure/edge;改完先跑相关单个测试再考虑全量。
- 命名描述性(`isRegisteredForDiscounts` 非 `discount()`);写新组件前先查既有可复用的。
- PHP:控制结构一律花括号;构造器属性提升;显式返回类型 + 参数类型;Enum 用 TitleCase;优先 PHPDoc。

## reviewer 额外检查维度

- named route / `casts()` 方法 / Pint 是否跑过 / N+1 与 `with()`/`load()` / FormRequest 一致性 / 是否用 Boost 工具(`database-query`)而非 raw SQL / 是否遵循既有目录结构。
