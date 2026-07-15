# Deltabadger Chart
===========

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.23.3](https://img.shields.io/badge/AppVersion-2.23.3-informational?style=flat-square)

A Helm chart for Deltabadger - Auto-DCA bot for crypto investments

## Overview

Deltabadger is an auto-DCA (Dollar Cost Averaging) bot for crypto investments. This Helm chart deploys Deltabadger using the [bjw-s common library](https://github.com/bjw-s-labs/helm-charts) chart.

## Prerequisites

- Kubernetes >= 1.19
- Helm >= 3.x
- The bjw-s common library dependency (pulled automatically via `helm dependency update`)

## Installation

### Installation via Helm

1. Add the Helm chart repo

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
```

2. Inspect & modify the default values (optional)

```bash
helm show values k8s-charts/deltabadger > custom-values.yaml
```

3. Install the chart

```bash
helm upgrade --install deltabadger k8s-charts/deltabadger -f custom-values.yaml
```

## Configuration

This chart uses the [bjw-s common library](https://bjw-s-labs.github.io/helm-charts/) for templating. The values follow the bjw-s structure rather than the flat format used by other charts in this repo.

### Key Configuration Sections

| Section | Description |
|---------|-------------|
| `controllers.deltabadger` | Main controller (deployment) configuration |
| `controllers.deltabadger.containers.app.image` | Container image settings |
| `controllers.deltabadger.containers.app.env` | Environment variables |
| `service.app` | Service configuration (default: ClusterIP on port 3000) |
| `ingress.app` | Ingress configuration (disabled by default) |
| `persistence.storage` | Persistent storage for SQLite databases (10Gi default) |
| `configMaps.config` | Optional ConfigMap for performance tuning / SMTP |
| `secrets.secrets` | Optional secrets (Rails secret key base, SMTP password) |

### Secrets

Since Deltabadger 2.x, no secrets are required: `SECRET_KEY_BASE` is
auto-generated on first start and persisted to `/app/storage/.secrets` on the
PVC (make sure it is part of your backups — the database encryption keys are
derived from it). To manage it yourself instead, generate one with
`openssl rand -hex 64` and set it under `secrets.secrets.stringData` (an
env-provided value takes precedence over the generated one).

### Upgrading from chart 1.x (app 1.6.x)

The 2.x image removed the `/health-check` endpoint (probes now use `/up` —
handled by the chart defaults) and made `DEVISE_SECRET_KEY` /
`APP_ENCRYPTION_KEY` legacy keys, read only by the one-time
`MigrateToRailsEncryption` migration. When upgrading an existing 1.x install,
keep providing the exact `SECRET_KEY_BASE`, `DEVISE_SECRET_KEY` and
`APP_ENCRYPTION_KEY` values your 1.x release ran with (chart 2.x disables the
chart-managed Secret by default — re-enable it with your old values). After the
migration, the two legacy keys can be removed, but `SECRET_KEY_BASE` must be
kept unchanged forever. See [QUICKSTART.md](QUICKSTART.md) for details.

## Values

The following table lists the configurable parameters of the Deltabadger chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configMaps | object | `{"config":{"data":{},"enabled":false}}` | ConfigMap for optional configuration |
| configMaps.config.data | object | See values.yaml for available options | ConfigMap data (performance tuning, SMTP settings, etc.) |
| configMaps.config.enabled | bool | `false` | Enable the config ConfigMap |
| controllers | object | `{"deltabadger":{"containers":{"app":{"args":["standalone"],"env":{"APP_ROOT_URL":"http://deltabadger.local","FORCE_SSL":"false","HOME_PAGE_URL":"http://deltabadger.local","NODE_ENV":"production","ORDERS_FREQUENCY_LIMIT":"60","RAILS_ENV":"production","RAILS_LOG_TO_STDOUT":"true","RAILS_SERVE_STATIC_FILES":"true"},"envFrom":[{"configMapRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}-config","optional":true}},{"secretRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}","optional":true}}],"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/deltabadger/deltabadger","tag":"{{ .Chart.AppVersion }}"},"probes":{"liveness":{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/up","port":3000,"scheme":"HTTP"},"initialDelaySeconds":60,"periodSeconds":30,"timeoutSeconds":10}},"readiness":{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/up","port":3000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}}},"resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false}}},"enabled":true,"replicas":1,"strategy":"Recreate","type":"deployment"}}` | Controller configuration (bjw-s common library format) |
| controllers.deltabadger.containers.app.args | list | `["standalone"]` | Container arguments (standalone mode runs web + jobs in one process) |
| controllers.deltabadger.containers.app.env.APP_ROOT_URL | string | `"http://deltabadger.local"` | Application root URL |
| controllers.deltabadger.containers.app.env.FORCE_SSL | string | `"false"` | Force SSL (set to "true" for HTTPS) |
| controllers.deltabadger.containers.app.env.HOME_PAGE_URL | string | `"http://deltabadger.local"` | Home page URL |
| controllers.deltabadger.containers.app.env.NODE_ENV | string | `"production"` | Node environment |
| controllers.deltabadger.containers.app.env.ORDERS_FREQUENCY_LIMIT | string | `"60"` | Minimum seconds between orders |
| controllers.deltabadger.containers.app.env.RAILS_ENV | string | `"production"` | Rails environment |
| controllers.deltabadger.containers.app.env.RAILS_LOG_TO_STDOUT | string | `"true"` | Log to stdout |
| controllers.deltabadger.containers.app.env.RAILS_SERVE_STATIC_FILES | string | `"true"` | Serve static files from Rails |
| controllers.deltabadger.containers.app.envFrom | list | `[{"configMapRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}-config","optional":true}},{"secretRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}","optional":true}}]` | Env from ConfigMap and Secret |
| controllers.deltabadger.containers.app.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| controllers.deltabadger.containers.app.image.repository | string | `"ghcr.io/deltabadger/deltabadger"` | Image repository |
| controllers.deltabadger.containers.app.image.tag | string | `"{{ .Chart.AppVersion }}"` | Image tag |
| controllers.deltabadger.containers.app.probes.liveness | object | `{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/up","port":3000,"scheme":"HTTP"},"initialDelaySeconds":60,"periodSeconds":30,"timeoutSeconds":10}}` | Liveness probe configuration |
| controllers.deltabadger.containers.app.probes.readiness | object | `{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/up","port":3000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}}` | Readiness probe configuration |
| controllers.deltabadger.containers.app.resources | object | `{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource limits and requests |
| controllers.deltabadger.containers.app.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false}` | Container security context |
| controllers.deltabadger.enabled | bool | `true` | Enable the deltabadger controller |
| controllers.deltabadger.replicas | int | `1` | Number of replicas |
| controllers.deltabadger.strategy | string | `"Recreate"` | Deployment strategy |
| controllers.deltabadger.type | string | `"deployment"` | Controller type |
| defaultPodOptions | object | `{"securityContext":{"fsGroup":1000,"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}}}` | Default pod-level security context |
| ingress | object | `{"app":{"annotations":{},"className":"nginx","enabled":false,"hosts":[{"host":"deltabadger.local","paths":[{"path":"/","pathType":"Prefix","service":{"identifier":"app","port":"http"}}]}],"tls":[]}}` | Ingress configuration |
| ingress.app.annotations | object | `{}` | Ingress annotations |
| ingress.app.className | string | `"nginx"` | Ingress class name |
| ingress.app.enabled | bool | `false` | Enable ingress |
| ingress.app.hosts | list | `[{"host":"deltabadger.local","paths":[{"path":"/","pathType":"Prefix","service":{"identifier":"app","port":"http"}}]}]` | Ingress hosts |
| ingress.app.tls | list | `[]` | Ingress TLS configuration |
| persistence | object | `{"storage":{"accessMode":"ReadWriteOnce","enabled":true,"globalMounts":[{"path":"/app/storage"}],"retain":true,"size":"10Gi","storageClass":"","type":"persistentVolumeClaim"}}` | Persistence configuration for SQLite databases and storage |
| persistence.storage.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.storage.enabled | bool | `true` | Enable persistent storage |
| persistence.storage.globalMounts | list | `[{"path":"/app/storage"}]` | Mount path in the container |
| persistence.storage.retain | bool | `true` | Retain PVC on chart uninstall |
| persistence.storage.size | string | `"10Gi"` | Storage size |
| persistence.storage.storageClass | string | `""` | Storage class (empty string uses default) |
| persistence.storage.type | string | `"persistentVolumeClaim"` | PVC type |
| secrets | object | Disabled - see values.yaml for available keys | Secrets configuration. Since app v2, SECRET_KEY_BASE is auto-generated on first start and persisted to /app/storage/.secrets on the PVC, so no Secret is required for new installs. An env-provided SECRET_KEY_BASE always takes precedence over the generated one. |
| secrets.secrets.enabled | bool | `false` | Enable the chart-managed secrets Secret |
| secrets.secrets.stringData | object | Empty - secrets are auto-generated by the app | Secret string data (all keys optional since app v2) |
| service | object | `{"app":{"controller":"deltabadger","ports":{"http":{"port":3000,"protocol":"HTTP"}},"type":"ClusterIP"}}` | Service configuration |
| service.app.controller | string | `"deltabadger"` | Controller to associate the service with |
| service.app.ports.http.port | int | `3000` | Service port |
| service.app.ports.http.protocol | string | `"HTTP"` | Port protocol |
| service.app.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{"create":true}` | Service account configuration |
| serviceAccount.create | bool | `true` | Create a service account |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
