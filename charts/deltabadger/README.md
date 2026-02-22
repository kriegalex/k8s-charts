# Deltabadger Chart
===========

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.26](https://img.shields.io/badge/AppVersion-1.6.26-informational?style=flat-square)

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
| `secrets.secrets` | Required secrets (Rails keys, encryption key) |

### Required Secrets

Before deploying to production, generate new secrets:

```bash
# Secret key base
openssl rand -hex 64

# Devise secret key
openssl rand -hex 64

# App encryption key
openssl rand -hex 32
```

Set them in your custom values file under `secrets.secrets.stringData`.

## Values

The following table lists the configurable parameters of the Deltabadger chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configMaps | object | `{"config":{"data":{},"enabled":false}}` | ConfigMap for optional configuration |
| configMaps.config.data | object | See values.yaml for available options | ConfigMap data (performance tuning, SMTP settings, etc.) |
| configMaps.config.enabled | bool | `false` | Enable the config ConfigMap |
| controllers | object | `{"deltabadger":{"containers":{"app":{"args":["standalone"],"env":{"APP_ROOT_URL":"http://deltabadger.local","FORCE_SSL":"false","HOME_PAGE_URL":"http://deltabadger.local","NODE_ENV":"production","ORDERS_FREQUENCY_LIMIT":"60","RAILS_ENV":"production","RAILS_LOG_TO_STDOUT":"true","RAILS_SERVE_STATIC_FILES":"true"},"envFrom":[{"configMapRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}-config","optional":true}},{"secretRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}"}}],"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/deltabadger/deltabadger","tag":"{{ .Chart.AppVersion }}"},"probes":{"liveness":{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/health-check","port":3000,"scheme":"HTTP"},"initialDelaySeconds":60,"periodSeconds":30,"timeoutSeconds":10}},"readiness":{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/health-check","port":3000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}}},"resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false}}},"enabled":true,"replicas":1,"strategy":"Recreate","type":"deployment"}}` | Controller configuration (bjw-s common library format) |
| controllers.deltabadger.containers.app.args | list | `["standalone"]` | Container arguments (standalone mode runs web + jobs in one process) |
| controllers.deltabadger.containers.app.env.APP_ROOT_URL | string | `"http://deltabadger.local"` | Application root URL |
| controllers.deltabadger.containers.app.env.FORCE_SSL | string | `"false"` | Force SSL (set to "true" for HTTPS) |
| controllers.deltabadger.containers.app.env.HOME_PAGE_URL | string | `"http://deltabadger.local"` | Home page URL |
| controllers.deltabadger.containers.app.env.NODE_ENV | string | `"production"` | Node environment |
| controllers.deltabadger.containers.app.env.ORDERS_FREQUENCY_LIMIT | string | `"60"` | Minimum seconds between orders |
| controllers.deltabadger.containers.app.env.RAILS_ENV | string | `"production"` | Rails environment |
| controllers.deltabadger.containers.app.env.RAILS_LOG_TO_STDOUT | string | `"true"` | Log to stdout |
| controllers.deltabadger.containers.app.env.RAILS_SERVE_STATIC_FILES | string | `"true"` | Serve static files from Rails |
| controllers.deltabadger.containers.app.envFrom | list | `[{"configMapRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}-config","optional":true}},{"secretRef":{"name":"{{ include \"bjw-s.common.lib.chart.names.fullname\" $ }}"}}]` | Env from ConfigMap and Secret |
| controllers.deltabadger.containers.app.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| controllers.deltabadger.containers.app.image.repository | string | `"ghcr.io/deltabadger/deltabadger"` | Image repository |
| controllers.deltabadger.containers.app.image.tag | string | `"{{ .Chart.AppVersion }}"` | Image tag |
| controllers.deltabadger.containers.app.probes.liveness | object | `{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/health-check","port":3000,"scheme":"HTTP"},"initialDelaySeconds":60,"periodSeconds":30,"timeoutSeconds":10}}` | Liveness probe configuration |
| controllers.deltabadger.containers.app.probes.readiness | object | `{"custom":true,"enabled":true,"spec":{"failureThreshold":3,"httpGet":{"path":"/health-check","port":3000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}}` | Readiness probe configuration |
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
| secrets | object | See values.yaml for required secrets | Secrets configuration |
| secrets.secrets.enabled | bool | `true` | Enable the secrets Secret |
| secrets.secrets.stringData | object | Development placeholder values - must be changed for production | Secret string data (IMPORTANT: change these for production!) |
| service | object | `{"app":{"controller":"deltabadger","ports":{"http":{"port":3000,"protocol":"HTTP"}},"type":"ClusterIP"}}` | Service configuration |
| service.app.controller | string | `"deltabadger"` | Controller to associate the service with |
| service.app.ports.http.port | int | `3000` | Service port |
| service.app.ports.http.protocol | string | `"HTTP"` | Port protocol |
| service.app.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{"create":true}` | Service account configuration |
| serviceAccount.create | bool | `true` | Create a service account |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
