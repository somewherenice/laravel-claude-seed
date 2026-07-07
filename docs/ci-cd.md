# CI/CD 约定

> 模板:`docs/ci-templates/github-actions.yml`,复制到项目 `.github/workflows/ci.yml` 生效。

## CI 跑什么

合并到 `main` 前,CI 必须绿。三件事并行跑:

| Job | 命令 | 作用 | 必过 |
|---|---|---|---|
| PHPUnit | `php artisan test --compact` | 全套测试 | 是 |
| Pint | `vendor/bin/pint --test` | 格式不合规直接红(本地 PostEdit hook 已自动修,CI 兜底) | 是 |
| Audit | `composer audit` | 依赖已知漏洞扫描 | 是 |

## 本地复现 CI

推送前本地跑一遍,省一次 CI 红轮:

```bash
php artisan test --compact && vendor/bin/pint --test && composer audit
```

## 门禁策略

- **PR 必须三 job 全绿才合并**(GitHub Branch Protection → Require status checks)。
- **覆盖率可选**:模板里注释了 `--coverage-clover` + Codecov 上传,要的话把 setup-php 的 `coverage: none` 改 `xdebug` 并取消注释。不强制门禁,只做趋势参考。
- **Pint 本地已自动化**(PostEdit hook),CI 的 `--test` 是兜底——本地漏了 CI 挡。

## 与其他约定的关系

- 串起 `commit-conventions` 的 PR 流程:PR 模板里的「测试」项,CI 用客观结果替代人肉声明。
- 部署前的前置:`deployment-checklist` 假设合并的代码已过 CI;Branch Protection 是这条假设的保证。
- 失败定位:三 job 分开,红哪个看哪个,不混在一坨日志里。

## 不在该 CI 跑的

- **部署动作**:CI 只验证,不部署。部署走 Laravel Cloud / 自建流水线的 deploy hook(见 `deployment-checklist.md`)。CD 单独配,不混进 CI。
- **端到端 / 浏览器测试**(Dusk):重,单独 workflow + 按需触发,不阻塞每次 PR。
