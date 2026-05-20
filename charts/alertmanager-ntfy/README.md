# alertmanager-ntfy

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Bridge that receives Alertmanager webhooks and forwards them to a ntfy server.

## Introduction

This chart deploys [xenrox/ntfy-alertmanager](https://codeberg.org/xenrox/ntfy-alertmanager), a small bridge that receives Alertmanager webhooks and forwards them to a [ntfy](https://ntfy.sh) server with per-severity priority/tags/icons.

It is a fork of the chart that ships in `xenrox/ntfy-alertmanager`'s `contrib/charts/` directory, extended to expose the full set of [scfg config options](https://codeberg.org/xenrox/ntfy-alertmanager/src/branch/master/config.scfg) the upstream binary supports — including `alert-mode`, `ntfy.template-path`, `ntfy.generator-url-label`, `resolved.update-notification`, the `alertmanager{}` silence-button block, and the `cache{}` block. The upstream chart only renders a small whitelist; this fork renders everything so you can tune notification verbosity without post-render patches.

## License

The upstream binary and chart are licensed under **AGPL-3.0**. This fork inherits that license — see [`LICENSE`](./LICENSE) and [`NOTICE`](./NOTICE) in this directory. The remainder of the [`kriegalex/k8s-charts`](https://github.com/kriegalex/k8s-charts) repository is MIT; only this chart subtree is AGPL-3.0.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.16+
- A reachable ntfy server (in-cluster or external) with a publisher credential

## Installing the Chart

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
helm repo update
helm install alertmanager-ntfy k8s-charts/alertmanager-ntfy \
  --namespace ntfy --create-namespace \
  -f values.yaml -f helm-values-secret.yaml
```

Credentials (the ntfy publisher password, optional webhook basic-auth) belong in a separate gitignored `helm-values-secret.yaml` so they don't land in version control.

## Reducing notification verbosity

The upstream binary's default formatter dumps every label and annotation into the notification body. Three knobs cut that down considerably on a phone:

```yaml
ntfyAlertmanager:
  alertMode: single                # one ntfy message per alert; cleaner title
  ntfy:
    generatorUrlLabel: "View"      # adds an action button to the Prometheus alert URL
  resolved:
    updateNotification: true       # updates the original notification on resolve

  # Optional: replace the default label/annotation dump with your own template.
  template:
    enabled: true
    body: |
      **{{ index .CommonAnnotations "summary" }}**

      {{ index .CommonAnnotations "description" }}

  # When alertMode is "single", enable a cache so re-evaluations of the same
  # alert don't re-publish on every Alertmanager group_interval.
  cache:
    type: memory
    duration: 24h
```

When `template.enabled` is true, the chart writes the template body into the config Secret as a second key (`template.tmpl`), mounts it at `/etc/ntfy-alertmanager/template.tmpl`, and sets `ntfy.template-path` automatically.

> **Pair `alertMode: single` with a cache.** In single mode the bridge does not deduplicate per-alert by default — every Alertmanager re-evaluation (typically every 30 s while the alert is firing) re-publishes. Set `ntfyAlertmanager.cache.type: memory` and a duration matching your `repeat_interval` to suppress recurrences.

## Silence button (optional)

To enable the in-notification "Silence" button:

```yaml
ntfyAlertmanager:
  baseURL: https://alertmanager-ntfy.example.com
  alertmanager:
    silenceDuration: 24h

ingress:
  enabled: true
  hosts:
    - host: alertmanager-ntfy.example.com
      paths:
        - path: /
          pathType: Prefix
```

The Silence button on each ntfy message posts back to this Ingress, which the bridge proxies on to the Alertmanager API.

## Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling. |
| autoscaling.enabled | bool | `false` | Enable HorizontalPodAutoscaler. |
| autoscaling.maxReplicas | int | `5` | Maximum replicas under autoscaling. |
| autoscaling.minReplicas | int | `1` | Minimum replicas under autoscaling. |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage. |
| autoscaling.targetMemoryUtilizationPercentage | string | `""` | Target memory utilization percentage. |
| fullnameOverride | string | `""` | Override the fully qualified app name. |
| global.image.pullPolicy | string | `""` | Overwrites all imagePullPolicy entries if set. |
| global.image.registry | string | `""` | Overwrites all registry entries if set. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy (overridable via global.image.pullPolicy). |
| image.registry | string | `"codeberg.org"` | Image registry (overridable via global.image.registry). |
| image.repository | string | `"xenrox/ntfy-alertmanager"` | Image repository. |
| image.tag | string | `""` | Image tag. When empty, defaults to .Chart.AppVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets. |
| ingress.annotations | object | `{}` | Ingress annotations. |
| ingress.className | string | `""` | IngressClass name. |
| ingress.enabled | bool | `false` | Expose the bridge through an Ingress (needed for the Silence button). |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts/paths. |
| ingress.tls | list | `[]` | Ingress TLS configuration. |
| nameOverride | string | `""` | Override the chart name used in resource names. |
| nodeSelector | object | `{}` | Node selector for pod scheduling. |
| ntfyAlertmanager.alertMode | string | `""` | How alerts are grouped into ntfy messages. "multi" keeps grouped alerts in one notification; "single" sends each alert separately (cleaner title, enables generator-url-label button). |
| ntfyAlertmanager.alertmanager.password | string | `""` | Alertmanager basic-auth password. |
| ntfyAlertmanager.alertmanager.silenceDuration | string | `""` | How long a silence created from the notification lasts (e.g. "24h"). |
| ntfyAlertmanager.alertmanager.url | string | `""` | Override the Alertmanager URL parsed from the webhook payload. |
| ntfyAlertmanager.alertmanager.user | string | `""` | Alertmanager basic-auth user when the API is protected. |
| ntfyAlertmanager.baseURL | string | `""` | Public-facing base URL of the bridge. Required if you want the "Silence" action button (alertmanager.silenceDuration) to work. |
| ntfyAlertmanager.cache.cleanupInterval | string | `""` | Memory cache cleanup interval. |
| ntfyAlertmanager.cache.duration | string | `""` | How long entries stay in the cache. |
| ntfyAlertmanager.cache.redisURL | string | `""` | Redis URL (only used when type is redis). |
| ntfyAlertmanager.cache.type | string | `""` | Cache backend (disabled, memory, redis). |
| ntfyAlertmanager.labels.entries | list | `[{"label":"severity","priority":5,"tags":["rotating_light"],"value":"critical"},{"label":"severity","priority":1,"value":"info"}]` | Per-label mapping entries. Each entry takes `label`, `value`, and any of: `priority`, `tags` (list), `icon`, `emailAddress`, `call`, `topic`. |
| ntfyAlertmanager.labels.order | list | `["severity","instance"]` | Decreasing-priority list of label names to consult. |
| ntfyAlertmanager.logFormat | string | `""` | Log format (text or json). |
| ntfyAlertmanager.logLevel | string | `"info"` | Log level (debug, info, warning, error). |
| ntfyAlertmanager.ntfy.accessToken | string | `""` | ntfy access token (alternative to user/password). |
| ntfyAlertmanager.ntfy.call | string | `""` | Place a phone call for every alert (use "yes" for first verified). |
| ntfyAlertmanager.ntfy.certificateFingerprint | string | `""` | SHA-512 certificate fingerprint for self-signed ntfy servers. |
| ntfyAlertmanager.ntfy.emailAddress | string | `""` | Forward every alert to this email address via ntfy. |
| ntfyAlertmanager.ntfy.generatorUrlLabel | string | `""` | Label for the action button that opens the alert's generator/Prometheus URL. Only effective when alertMode is "single". Example: "View". |
| ntfyAlertmanager.ntfy.markdown | string | `""` | Render the notification body as Markdown. Empty = upstream default (true). |
| ntfyAlertmanager.ntfy.password | string | `""` | ntfy publisher password. |
| ntfyAlertmanager.ntfy.server | string | `""` | ntfy server URL when `topic` is just a topic name. |
| ntfyAlertmanager.ntfy.templatePath | string | `""` | Absolute path inside the pod to a Go text/template file that overrides the default notification body. When `template.enabled` is true and this is left empty, it auto-fills to /etc/ntfy-alertmanager/template.tmpl. |
| ntfyAlertmanager.ntfy.topic | string | `"https://ntfy.sh/alertmanager-alerts"` | URL of the ntfy topic (required). Either a full URL (https://ntfy.example.com/my-topic) or just the topic name when combined with `server`. |
| ntfyAlertmanager.ntfy.user | string | `""` | ntfy publisher username. |
| ntfyAlertmanager.password | string | `""` | HTTP basic auth password for the webhook endpoint. |
| ntfyAlertmanager.port | int | `80` | Listening port for the webhook receiver. |
| ntfyAlertmanager.resolved.icon | string | `""` | Icon URL for resolved-alert notifications. |
| ntfyAlertmanager.resolved.priority | string | `""` | ntfy priority for resolved-alert notifications. |
| ntfyAlertmanager.resolved.tags | list | `["white_check_mark"]` | Tags appended to resolved-alert notifications. |
| ntfyAlertmanager.resolved.updateNotification | bool | `false` | Update the original ntfy notification instead of pushing a new one when an alert resolves. Halves the notification count in practice. |
| ntfyAlertmanager.template.body | string | `""` | Go text/template source. See xenrox/ntfy-alertmanager docs for the available `.Alerts[]`, `.CommonLabels`, `.CommonAnnotations`, etc. |
| ntfyAlertmanager.template.enabled | bool | `false` | Render the template ConfigMap and mount it into the pod. |
| ntfyAlertmanager.user | string | `""` | Optional HTTP basic auth on the webhook endpoint itself (Alertmanager -> bridge). Leave empty for in-cluster trust. |
| podAnnotations | object | `{}` | Extra annotations added to every Pod. |
| podLabels | object | `{}` | Extra labels added to every Pod. |
| podSecurityContext | object | `{}` | Pod-level securityContext. |
| replicaCount | int | `1` | Number of replicas. |
| resources | object | `{}` | Container resources. |
| securityContext | object | `{}` | Container-level securityContext. |
| service.port | int | `80` | Service port. |
| service.type | string | `"ClusterIP"` | Service type. |
| serviceAccount.annotations | object | `{}` | Service account annotations. |
| serviceAccount.create | bool | `true` | Create a service account for the bridge. |
| serviceAccount.name | string | `""` | Pre-existing service account name. Generated if empty and create is true. |
| tolerations | list | `[]` | Tolerations for pod scheduling. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
