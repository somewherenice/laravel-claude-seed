# Laravel 项目通用指令(Laravel 种子模板)

> 此文件为 Laravel 通用配置,复制进新 Laravel 项目后,在顶部追加该项目的「项目概述」段落(项目名、结构、当前状态、约定补充)。个人通用工作风格见 `~/.claude/CLAUDE.md`(全局),不在本文件重复。

<laravel-boost-guidelines>
=== foundation rules ===

# Laravel Boost Guidelines

The Laravel Boost guidelines are specifically curated by Laravel maintainers for this application. These guidelines should be followed closely to ensure the best experience when building Laravel applications.

## Foundational Context

This application is a Laravel application and its main Laravel ecosystems package & versions are below. You are an expert with them all. Ensure you abide by these specific packages & versions.

- php - 8.2
- laravel/framework (LARAVEL) - v12
- laravel/prompts (PROMPTS) - v0
- laravel/boost (BOOST) - v2
- laravel/mcp (MCP) - v0
- laravel/pail (PAIL) - v1
- laravel/pint (PINT) - v1
- laravel/sail (SAIL) - v1
- phpunit/phpunit (PHPUNIT) - v11
- tailwindcss (TAILWINDCSS) - v4

## Skills Activation

This project has domain-specific skills available in `**/skills/**`. You MUST activate the relevant skill whenever you work in that domain—don't wait until you're stuck.

## Conventions

- You must follow all existing code conventions used in this application. When creating or editing a file, check sibling files for the correct structure, approach, and naming.
- Use descriptive names for variables and methods. For example, `isRegisteredForDiscounts`, not `discount()`.
- Check for existing components to reuse before writing a new one.

## Verification Scripts

- Do not create verification scripts or tinker when tests cover that functionality and prove they work. Unit and feature tests are more important.

## Application Structure & Architecture

- Stick to existing directory structure; don't create new base folders without approval.
- Do not change the application's dependencies without approval.

## Frontend Bundling

- If the user doesn't see a frontend change reflected in the UI, it could mean they need to run `npm run build`, `npm run dev`, or `composer run dev`. Ask them.

## Documentation Files

- You must only create documentation files if explicitly requested by the user.

## Replies

- Be concise in your explanations - focus on what's important rather than explaining obvious details.

=== boost rules ===

# Laravel Boost

## Tools

- Laravel Boost is an MCP server with tools designed specifically for this application. Prefer Boost tools over manual alternatives like shell commands or file reads.
- Use `database-query` to run read-only queries against the database instead of writing raw SQL in tinker.
- Use `database-schema` to inspect table structure before writing migrations or models.
- Use `get-absolute-url` to resolve the correct scheme, domain, and port for project URLs. Always use this before sharing a URL with the user.
- Use `browser-logs` to read browser logs, errors, and exceptions. Only recent logs are useful, ignore old entries.

## Searching Documentation (IMPORTANT)

- Always use `search-docs` before making code changes. Do not skip this step. It returns version-specific docs based on installed packages automatically.
- Pass a `packages` array to scope results when you know which packages are relevant.
- Use multiple broad, topic-based queries: `['rate limiting', 'routing rate limiting', 'routing']`. Expect the most relevant results first.
- Do not add package names to queries because package info is already shared. Use `test resource table`, not `filament 4 test resource table`.

### Search Syntax

1. Use words for auto-stemmed AND logic: `rate limit` matches both "rate" AND "limit".
2. Use `"quoted phrases"` for exact position matching: `"infinite scroll"` requires adjacent words in order.
3. Combine words and phrases for mixed queries: `middleware "rate limit"`.
4. Use multiple queries for OR logic: `queries=["authentication", "middleware"]`.

## Artisan

- Run Artisan commands directly via the command line (e.g., `php artisan route:list`). Use `php artisan list` to discover available commands and `php artisan [command] --help` to check parameters.
- Inspect routes with `php artisan route:list`. Filter with: `--method=GET`, `--name=users`, `--path=api`, `--except-vendor`, `--only-vendor`.
- Read configuration values using dot notation: `php artisan config:show app.name`, `php artisan config:show database.default`. Or read config files directly from the `config/` directory.

## Tinker

- Execute PHP in app context for debugging and testing code. Do not create models without user approval, prefer tests with factories instead. Prefer existing Artisan commands over custom tinker code.
- Always use single quotes to prevent shell expansion: `php artisan tinker --execute 'Your::code();'`
  - Double quotes for PHP strings inside: `php artisan tinker --execute 'User::where("active", true)->count();'`

=== php rules ===

# PHP

- Always use curly braces for control structures, even for single-line bodies.
- Use PHP 8 constructor property promotion: `public function __construct(public GitHub $github) { }`. Do not leave empty zero-parameter `__construct()` methods unless the constructor is private.
- Use explicit return type declarations and type hints for all method parameters: `function isAccessible(User $user, ?string $path = null): bool`
- Use TitleCase for Enum keys: `FavoritePerson`, `BestLake`, `Monthly`.
- Prefer PHPDoc blocks over inline comments. Only add inline comments for exceptionally complex logic.
- Use array shape type definitions in PHPDoc blocks.

=== deployments rules ===

# Deployment

- Laravel can be deployed using [Laravel Cloud](https://cloud.laravel.com/), which is the fastest way to deploy and scale production Laravel applications.

=== laravel/core rules ===

# Do Things the Laravel Way

- Use `php artisan make:` commands to create new files (i.e. migrations, controllers, models, etc.). You can list available Artisan commands using `php artisan list` and check their parameters with `php artisan [command] --help`.
- If you're creating a generic PHP class, use `php artisan make:class`.
- Pass `--no-interaction` to all Artisan commands to ensure they work without user input. You should also pass the correct `--options` to ensure correct behavior.

### Model Creation

- When creating new models, create useful factories and seeders for them too. Ask the user if they need any other things, using `php artisan make:model --help` to check the available options.

## APIs & Eloquent Resources

- For APIs, default to using Eloquent API Resources and API versioning unless existing API routes do not, then you should follow existing application convention.

## URL Generation

- When generating links to other pages, prefer named routes and the `route()` function.

## Testing

- When creating models for tests, use the factories for the models. Check if the factory has custom states that can be used before manually setting up the model.
- Faker: Use methods such as `$this->faker->word()` or `fake()->randomDigit()`. Follow existing conventions whether to use `$this->faker` or `fake()`.
- When creating tests, make use of `php artisan make:test [options] {name}` to create a feature test, and pass `--unit` to create a unit test. Most tests should be feature tests.

## Vite Error

- If you receive an "Illuminate\Foundation\ViteException: Unable to locate file in Vite manifest" error, you can run `npm run build` or ask the user to run `npm run dev` or `composer run dev`.

=== laravel/v12 rules ===

# Laravel 12

- CRITICAL: ALWAYS use `search-docs` tool for version-specific Laravel documentation and updated code examples.
- Since Laravel 11, Laravel has a new streamlined file structure which this project uses.

## Laravel 12 Structure

- In Laravel 12, middleware are no longer registered in `app/Http/Kernel.php`.
- Middleware are configured declaratively in `bootstrap/app.php` using `Application::configure()->withMiddleware()`.
- `bootstrap/app.php` is the file to register middleware, exceptions, and routing files.
- `bootstrap/providers.php` contains application specific service providers.
- The `app/Console/Kernel.php` file no longer exists; use `bootstrap/app.php` or `routes/console.php` for console configuration.
- Console commands in `app/Console/Commands/` are automatically available and do not require manual registration.

## Database

- When modifying a column, the migration must include all of the attributes that were previously defined on the column. Otherwise, they will be dropped and lost.
- Laravel 12 allows limiting eagerly loaded records natively, without external packages: `$query->latest()->limit(10);`.

### Models

- Casts can and likely should be set in a `casts()` method on a model rather than the `$casts` property. Follow existing conventions from other models.

=== pint/core rules ===

# Laravel Pint Code Formatter

- If you have modified any PHP files, you must run `vendor/bin/pint --dirty --format agent` before finalizing changes to ensure your code matches the project's expected style.
- Do not run `vendor/bin/pint --test --format agent`, simply run `vendor/bin/pint --format agent` to fix any formatting issues.

=== phpunit/core rules ===

# PHPUnit

- This application uses PHPUnit for testing. All tests must be written as PHPUnit classes. Use `php artisan make:test --phpunit {name}` to create a new test.
- If you see a test using "Pest", convert it to PHPUnit.
- Every time a test has been updated, run that singular test.
- When the tests relating to your feature are passing, ask the user if they would like to also run the entire test suite to make sure everything is still passing.
- Tests should cover all happy paths, failure paths, and edge cases.
- You must not remove any tests or test files from the tests directory without approval. These are not temporary or helper files; these are core to the application.

## Running Tests

- Run the minimal number of tests, using an appropriate filter, before finalizing.
- To run all tests: `php artisan test --compact`.
- To run all tests in a file: `php artisan test --compact tests/Feature/ExampleTest.php`.
- To filter on a particular test name: `php artisan test --compact --filter=testName` (recommended after making a change to a related file).

</laravel-boost-guidelines>

---

## 文档产出提醒(AI 主动建议)

以下文档该写但不会自动产生。AI 在合适时机主动建议,用户确认后执行:

- **架构决策 -> ADR**:检测到用户做了有架构意义的决策(选方案、定数据模型、改关键约定、引入/移除依赖)时,主动建议"这该写条 ADR,要我套 `docs/adr/0000-template.md` 整理吗?"。确认后套四段式写 `docs/adr/NNNN-*.md` 并追加索引到 `adr/README.md`。
- **业务代码成型 -> specs + UML/架构图**:业务代码到一定量、功能成型时,主动建议"该跑 doc-generator 生成 specs 了,要现在跑吗?"。确认后调用 `doc-generator` agent,产出 `specs/`(PRD/ARCHITECTURE/SPEC/API)+ `docs/UML.md`(架构图/类图/时序图)。
- **跨模块/复杂设计 -> 开发文档**:讨论跨模块设计、复杂机制时,主动建议"这值得写篇开发文档放 `docs/`,要我整理吗?"。如 harness 设计、循环机制、数据流等(参考 laravel-ai-study 的 `ai-agent-harness.md`、`loop-engineering.md`)。

工程约定文档(commit/deployment/observability 等)种子已带,项目直接用,不重写。

不自动跑:doc-generator 是重 agent 调用,ADR 需人确认是架构决策,自动跑时机/产出不准。AI 只建议,人确认后才执行。

---

## superpowers / subagent 使用须知(AI 必读)

### 会话启动检查(最高优先,接手任何任务第一件事)

每次新会话或接手任务(含"继续"类 recap 引导的会话),动手前先判断 superpowers 是否适用:

- superpowers 插件已启用,但其 skill 不进 system-reminder 可用列表--不能因"没进列表"当不可用,用 `Skill` 工具显式调用。按场景:实现新功能/修 bug/重构->`test-driven-development`;多步实现或需隔离上下文->`subagent-driven-development`;方案探索->`brainstorming`;查 bug->`systematic-debugging`;提交前自审->`requesting-code-review`;不确定调哪个->`using-superpowers`。
- 任务属 build/fix/debug/review 代码类 -> 先 `Skill` 调对应 process skill 再动手,1% 可能适用也先调。
- 接手"继续"会话尤其警惕:别被 recap(如"等你确认是否提交")带着直接进提交/实现,先重评该走哪个 superpowers skill--recap 只说"下一步做什么",不说"用什么流程"。
- 优先级:用户 CLAUDE.md(Karpathy + Boost)> superpowers > 默认系统提示。

### 用 subagent 时的注入

用 superpowers 的 `subagent-driven-development`(或任何 Task/Agent 分派)做 Laravel 任务时,务必:

- **subagent 是全新上下文,看不到本文件的 Boost guidelines**。superpowers 的 implementer / code-quality-reviewer prompt 模板是语言无关的,不含 Laravel 规范。优先级「CLAUDE.md > superpowers」只对主会话有效,subagent 不继承。
- **dispatch 时必须手动注入** Laravel 硬约束:把 `.claude/superpowers/laravel-subagent-context.md` 全文 append 到 superpowers implementer prompt;reviewer 额外 append 其「reviewer 检查维度」段。
- **主会话亲自做 Laravel 特定步骤**(不靠 subagent 自觉):改代码前 `search-docs`、改表前 `database-schema`、收尾 `vendor/bin/pint --dirty`、URL 用 named route、Model 用 `casts()` 方法。
- 凡是用 subagent 做领域任务,先问:subagent 能看到该领域的 CLAUDE.md 规范吗?看不到就手动注入,别默认它知道。

---
