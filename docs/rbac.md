# RBAC 约定(自建,不引 spatie/laravel-permission)

所有新 Laravel 项目须实现自建 RBAC(角色 + 权限点 + 多 guard 支持)。

## 数据模型

- `roles` 表:`name`、`slug`(unique)、`permissions`(json,权限点字符串数组)、`is_system`(系统内置不可删)。
- `role_user` 表(**多态 morph**):`role_id` + `user_type` + `user_id`,支持多 guard 用户模型(User / SsoUser)共用一套角色。
- 系统内置 `super-admin` 角色(`is_system=true`、`permissions=[]`),迁移时创建。

## 权限点

- `App\Support\Permission` enum 集中定义所有权限点(TitleCase case + 字符串值,如 `DashboardView = 'dash.view'`),`values()` 返回全量。
- 路由用 `->middleware('can:<permission>')` 挂权限点。

## 模型约定

- `App\Support\HasRoles` trait,User / SsoUser 均使用:
  - `roles()`:MorphToMany(Role)
  - `hasRole(string $slug): bool`
  - `hasPermission(string $ability): bool`(汇总所有角色的 permissions)
  - `assignRole(name, slug, permissions, system): Role`(firstOrCreate 角色 + attach)
- `Role` 模型:`permissions` cast 为 array,`is_system` cast 为 boolean。

## 授权(Gate)

- `AppServiceProvider::boot()` 注册 `Gate::before`:
  - `super-admin` 角色直接放行(return true);
  - 否则 `$user->hasPermission($ability) ? true : null`(null 继续后续检查)。
- `$user` 为 null 时返回 false(未登录无权限)。

## 多 guard 关键(翻车教训,必读)

- 本项目后台用 `sso` guard(生产)/`web` guard(本地),与 Laravel 默认 guard 不同。
- `Gate` 默认取**默认 guard** 用户。若不切默认 guard,后台用 sso 登录时 Gate 取 web guard 用户 = null,RBAC 在生产失效。
- **正解**:后台中间件(`AdminAuth`)内 `Auth::shouldUse(AdminDriver::guard())` 切默认 guard 为后台 guard,Gate 才能取到后台用户。
- 设计 RBAC/鉴权前**必读** `config/auth.php` 的 guards 定义,不凭框架一般情况脑补。

## 冷启动

- `php artisan rbac:init {identifier} {--type=sso|local}`:给指定用户(sso 按 nameid / local 按 email)分配 super-admin 角色。
