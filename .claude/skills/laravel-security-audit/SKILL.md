---
name: laravel-security-audit
description: "Invoke when the user asks to audit, review, or harden a Laravel application's security before deploy or as a periodic check — e.g. 'security audit', 'check for vulnerabilities', 'harden the app', 'is this safe to ship', 'pentest prep', 'OWASP check'. Provides a runnable checklist of grep/artisan commands across 7 dimensions (dependencies & runtime, route authorization, mass assignment, injection & output, file uploads, rate limiting & sessions, sensitive data) to discover what already slipped through. This is audit-time discovery, distinct from laravel-best-practices/rules/security.md which covers encoding-time rules. Skip for new feature work, styling, performance tuning, or non-security reviews."
license: MIT
metadata:
  author: fuyan
---

# Laravel Security Audit

Audit-time checklist for finding security issues already present in a Laravel codebase. Complements `laravel-best-practices/rules/security.md`:

- **That rule file** = encoding-time rules (what to do *while writing* code: define `$fillable`, add `@csrf`, apply `throttle`, use the `encrypted` cast).
- **This skill** = audit-time discovery (grep/artisan commands to find where those rules were *not* followed, plus environment & config checks that don't surface as code patterns).

Run dimension by dimension, record findings, then fix in a separate pass. Don't edit code mid-audit — partial fixes skew the remaining findings.

## How to use

- Prefer Boost tools: `database-query` for read-only SQL, `database-schema` to inspect columns, `search-docs` for version-specific config, `browser-logs` for runtime errors.
- Commands assume project root as cwd.
- For each finding record: `file:line`, severity (Critical/High/Medium/Low), one-line fix.

## 1. Dependencies & Runtime Environment

Config and environment issues that bypass code review entirely.

```bash
composer audit                                    # known CVEs in composer deps
php artisan config:show app.env                   # must be production in prod
php artisan config:show app.debug                 # must be false in prod
php artisan config:show app.key                   # must be set, not a placeholder
git ls-files | grep -E '(^|/)\.env$'              # .env must NOT be tracked (empty output = good)
grep -rn 'APP_KEY=base64:' .env.example 2>/dev/null  # example must hold a placeholder, not a real key
```

- `APP_DEBUG=true` in prod leaks stack traces with env values — **Critical**.
- `APP_KEY` missing or a `base64:CHANGE_ME`-style placeholder → encrypted cookies/IDs forgeable — **Critical**.
- `composer.lock` not committed → installed deps not pinned, audit results unreliable — **Medium**.
- Behind a reverse proxy / load balancer? Confirm trusted proxies (or `TrustHosts`) so `request()->ip()` and `Url::secure()` aren't spoofable — **High** if missing.

## 2. Route Authorization Matrix

Every mutating route and every sensitive read needs auth + a policy/gate.

```bash
php artisan route:list --except-vendor -v          # full route table with middleware
php artisan route:list --except-vendor --path=api  # API surface specifically
```

For each `POST/PUT/PATCH/DELETE` route and each sensitive `GET`:
- Is auth middleware applied (`auth`, `auth:api`, or route-group middleware)?
- Is there a policy/gate? In controllers: `$this->authorize(...)` / `Gate::authorize(...)`. In Form Requests: `authorize(): bool`. In Blade: `@can(...)`.

```bash
# Controllers that never call authorize/Gate — candidates for missing authz
grep -rLn 'authorize\|Gate::' app/Http/Controllers/
# Form Requests whose authorize() returns true unconditionally — verify each
grep -rn 'function authorize' -A2 app/Http/Requests/
```

- Controller action with no `authorize` call and no Form Request authz = **High**.
- `authorize(): bool { return true; }` on a request touching user-owned data = **High**.

## 3. Mass Assignment

```bash
grep -rn '\$guarded = \[\]' app/Models/            # wide-open models — High
grep -rLn '\$fillable\|\$guarded' app/Models/      # models with neither — High
grep -rn '->fill(\$request->all\|->update(\$request->all\|forceFill' app/  # user input into mass ops
```

- `$guarded = []` on any model accepting user input = **High**.
- `$request->all()` into `fill`/`update` instead of `$request->validated()` = **High**.
- `forceFill()` with user-controlled keys = **Critical** (bypasses `$fillable`).

## 4. Injection & Output

SQL injection (raw methods) and XSS (unescaped Blade output).

```bash
grep -rn 'whereRaw\|selectRaw\|orderByRaw\|havingRaw\|DB::raw\|DB::select\|DB::statement' app/
grep -rn '{!!' resources/views/                     # unescaped output
grep -rn '\beval(\|\bexec(\|\bsystem(\|\bshell_exec(\|\bpassthru(\|unserialize(' app/
```

For each `*Raw` / `DB::select` hit:
- String interpolation of user input (`"...$var..."`) = **Critical**.
- `?`-bindings or a parameter array = OK.

For each `{!! !!}` hit:
- Output is pre-sanitized or trusted static content = OK.
- Anything model- or request-derived = **High**.

`eval`/`exec`/`unserialize` with any user-reachable input = **Critical**.

## 5. File Uploads

```bash
grep -rn '\->file(\|\->hasFile(\|UploadedFile\|\->store(\|\->move(' app/
grep -rn 'getClientOriginalName\|getClientOriginalExtension' app/  # trusting client filename = High
grep -rn 'mimes:\|mimetypes:\|image\|max:' app/Http/Requests/      # validation present?
```

Per upload path:
- Validation rule covers MIME/extension **and** size — missing = **High**.
- Storage on the `public` disk or a web-root-exposed dir without validation = **High**.
- `getClientOriginalName()` used as the stored name (path traversal / clobber) = **High**; prefer `store()`, which generates a random name.
- `->move($dir, $clientName)` with a client-provided name = same issue.

## 6. Rate Limiting & Sessions

```bash
php artisan route:list --except-vendor | grep -i throttle   # which routes are throttled
grep -rn 'RateLimiter::for\|throttle:' routes/ app/
php artisan config:show session.secure            # should be true in prod
php artisan config:show session.same_site         # lax or strict
php artisan config:show session.http_only         # should be true
php artisan config:show cors.allowed_origins      # '*' in prod = High
grep -rn 'except\|WithoutMiddleware\|VerifyCsrfToken' app/ bootstrap/  # CSRF exclusions
```

- Auth / login / password-reset / API routes without `throttle` = **High** (credential stuffing).
- `session.secure=false` in prod = cookies sent over HTTP = **High**.
- `session.same_site=none` without `secure` = **High**.
- `cors.allowed_origins: ['*']` with `supports_credentials: true` = **High**.
- CSRF `$except` listing real app routes = **High** — verify each is intentional (e.g. a webhook with its own signature check).

## 7. Sensitive Data

```bash
grep -rn 'encrypted' app/Models/                  # sensitive fields should use the encrypted cast
grep -rLn '\$hidden' app/Models/                  # models with secrets but no $hidden
grep -rn 'password\|api_key\|secret\|token\|card' app/ | grep -i 'Log::\|->info(\|->debug(\|->all('  # logging or mass-passing secrets
grep -rn '\benv(' app/                            # env() outside config/ = reading raw secrets in app code
php artisan config:show telescope.enabled 2>/dev/null   # dev tools off in prod
php artisan config:show debugbar.enabled 2>/dev/null
```

- A column holding secrets (API keys, tokens) without the `encrypted` cast = **High**.
- Secrets in `$visible` (or not in `$hidden`) → leaked to JSON/array output = **High**.
- `Log::info($request->all())` on routes that accept passwords/tokens = **High**.
- `env()` called outside `config/*.php` = **Medium** (bypasses config caching, can't be overridden, leaks to `artisan` callers) — verify each hit is inside a config file.
- Telescope / Debugbar enabled in prod = **High** (exposes request bodies, queries, env).

## Triaging findings

- **Critical** — direct RCE / auth bypass / secret disclosure: fix before any deploy.
- **High** — account takeover, data leak, mass assignment: fix before prod; block behind authz if shipping sooner.
- **Medium** — info leak, missing hardening: fix soon.
- **Low** — defense-in-depth, hygiene: batch into next cleanup.

Output the audit as a table grouped by severity, each row with `file:line` and the one-line fix. Don't start fixing until the user has seen the full list — a partial fix pass makes the remaining findings harder to reason about.
