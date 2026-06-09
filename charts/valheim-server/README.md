# valheim-server

![Version: 1.2.0](https://img.shields.io/badge/Version-1.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.1.0](https://img.shields.io/badge/AppVersion-3.1.0-informational?style=flat-square)

A Helm chart for deploying a Valheim dedicated server on Kubernetes

**Homepage:** <https://www.valheimgame.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| kriegalex | <kriegalex@gmail.com> |  |

## Source Code

* <https://github.com/mbround18/valheim-docker>
* <https://github.com/kriegalex/k8s-charts/tree/main/charts/valheim-server>

## Overview

This Helm chart deploys a Valheim dedicated server based on the [mbround18/valheim-docker](https://github.com/mbround18/valheim-docker) project.

## Features

- Configurable server settings
- Automatic updates and backups
- Discord webhook notifications
- Persistent storage for game saves, server files, and backups
- Resource management for Kubernetes

## Prerequisites

- Kubernetes 1.29+
- Helm 3.16.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)
- LoadBalancer support or an Ingress controller

## TL;DR

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
helm install my-valheim-server k8s-charts/valheim-server
```

## Important Security Notice
The default values for this chart include a placeholder password. For production use:

1. Always specify a secure password
2. Consider using Kubernetes secrets for sensitive values
3. Restrict access to your server using appropriate network policies

## Installation

### Simple Install with Custom Password and Server Name

```bash
helm upgrade --install my-valheim-server \
  --set server.password="YourStrongPassword" \
  --set server.name="Your Awesome Valheim Server" \
  k8s-charts/valheim-server
```

### Custom Configuration File
Create a YAML file with your custom values:

```yaml
server:
  name: "My Custom Valheim Server"
  password: "SuperSecretPassword"
  world: "MyWorld"
  public: 1
 
persistence:
  saves:
    size: 5Gi
  backups:
    size: 20Gi
   
automation:
  autoBackup: 1  # disabled by default
  autoBackupSchedule: "*/30 * * * *"
 
resources:
  requests:
    memory: 4Gi
    cpu: 2000m
  limits:
    memory: 12Gi
    cpu: 4000m
```

Then install the chart:

```bash
helm install my-valheim-server -f my-values.yaml k8s-charts/valheim-server
```

## Updating

```bash
helm upgrade my-valheim-server k8s-charts/valheim-server
```

## Uninstallation

```bash
helm uninstall my-valheim-server
```

Note: This will not delete the Persistent Volume Claims. To delete them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=my-valheim-server
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| automation.autoBackup | int | `0` | Enable automatic backups (1=enabled, 0=disabled) |
| automation.autoBackupDaysToLive | int | `7` | Number of days to keep backups |
| automation.autoBackupOnShutdown | int | `0` | Create backup on server shutdown (1=enabled, 0=disabled) |
| automation.autoBackupOnUpdate | int | `1` | Create backup before updates (1=enabled, 0=disabled) |
| automation.autoBackupRemoveOld | int | `1` | Remove old backups automatically (1=enabled, 0=disabled) |
| automation.autoBackupSchedule | string | `"*/15 * * * *"` | Cron schedule for automatic backups |
| automation.autoUpdate | int | `1` | Enable automatic updates (1=enabled, 0=disabled) |
| automation.autoUpdateSchedule | string | `"0 1 * * *"` | Cron schedule for automatic updates |
| automation.scheduledRestart | int | `0` | Enable a scheduled server restart (1=enabled, 0=disabled) |
| automation.scheduledRestartSchedule | string | `"0 2 * * *"` | Cron schedule for the scheduled restart |
| automation.updateOnStartup | int | `0` | Update server when container starts (1=enabled, 0=disabled) |
| extraEnv | list | `[]` | Additional environment variables for the Valheim server |
| fullnameOverride | string | `""` | Provide a full name override for resources |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"mbround18/valheim"` | Docker repository to use |
| image.tag | string | `""` | Docker tag to use - use "latest" for most current version |
| initContainers | object | `{"args":[],"command":[],"enabled":false,"image":"busybox:latest"}` | Init container configuration for server preparation |
| initContainers.args | list | `[]` | Init container arguments |
| initContainers.command | list | `[]` | Init container command |
| initContainers.enabled | bool | `false` | Enable init container |
| initContainers.image | string | `"busybox:latest"` | Init container image |
| livenessProbe.enabled | bool | `false` | Enable liveness probe |
| livenessProbe.failureThreshold | int | 6 (allows up to 2 minutes for recovery) | Failure threshold |
| livenessProbe.initialDelaySeconds | int | `60` | Initial delay seconds |
| livenessProbe.periodSeconds | int | `20` | Period seconds |
| livenessProbe.timeoutSeconds | int | `5` | Timeout seconds |
| modding.bepInEx | int | `0` | Enable BepInEx mod loader (1=enabled, 0=disabled). When enabled, sets the container's TYPE=BepInEx. Mods and their config live in the persistent server PVC under BepInEx/, so they survive pod restarts. |
| modding.mods | list | `[]` | List of mods for the container to download on startup (requires bepInEx=1). Each entry is a Thunderstore dependency string (Author-Package-Version) or a direct URL. Supported files: zip, dll, cfg. |
| nameOverride | string | `""` | Provide a name override for resources |
| nodeSelector | object | `{}` | Node selector for pod assignment |
| notifications.includePublicIp | int | `0` | Include the server's public IP in notifications (1=enabled, 0=disabled) |
| notifications.webhookUrl | string | `""` | Discord webhook URL for server notifications |
| persistence.backups.accessMode | string | `"ReadWriteOnce"` | Access mode for the PVC |
| persistence.backups.existingClaim | string | `""` | Existing claim to use (leave empty to create a new one) |
| persistence.backups.size | string | `"10Gi"` | Size of PVC for backups |
| persistence.enabled | bool | `true` | Enable persistent storage for server data |
| persistence.saves.accessMode | string | `"ReadWriteOnce"` | Access mode for the PVC |
| persistence.saves.existingClaim | string | `""` | Existing claim to use (leave empty to create a new one) |
| persistence.saves.size | string | `"1Gi"` | Size of PVC for game saves |
| persistence.server.accessMode | string | `"ReadWriteOnce"` | Access mode for the PVC |
| persistence.server.existingClaim | string | `""` | Existing claim to use (leave empty to create a new one) |
| persistence.server.size | string | `"4Gi"` | Size of PVC for server files |
| persistence.storageClass | string | use default storage class | Storage class to use (use null for default or "" for no storage class) |
| podSecurityContext.fsGroup | int | `1000` | File system group ID for volume mounts |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | 20 (allows up to 5 minutes for readiness) | Failure threshold |
| readinessProbe.initialDelaySeconds | int | `60` | Initial delay seconds |
| readinessProbe.periodSeconds | int | `15` | Period seconds |
| readinessProbe.timeoutSeconds | int | `5` | Timeout seconds |
| replicaCount | int | `1` | Number of replicas to deploy (should typically stay at 1) |
| resources | object | `{}` | Resource requests and limits |
| securityContext.runAsGroup | int | `1000` | Group ID to run the container processes |
| securityContext.runAsNonRoot | bool | `true` | Force the container to run as a non-root user |
| securityContext.runAsUser | int | `111` | User ID to run the container processes. Should default to the steam user ID. |
| server.crossplay | int | `0` | Enable crossplay/PlayFab networking (1=enabled, 0=disabled). NOTE: crossplay is mutually exclusive with BepInEx mods — with crossplay on, mods will not load. |
| server.modifiers | string | `""` | World modifiers as space-separated "key value" pairs (e.g. "combat veryhard portals casual"). Leave empty to skip. |
| server.name | string | `"Valheim Server with Helm"` | Server name as displayed in-game |
| server.password | string | you MUST change this value | Server access password (minimum 5 characters) |
| server.port | int | `2456` | UDP port for game server (will use PORT, PORT+1, and PORT+2) |
| server.preset | string | `""` | World preset (e.g. Normal, Casual, Hard, Hardcore, Immersive, Hammer). Leave empty to skip. |
| server.public | int | `0` | Set to 1 to make server visible publicly, 0 for private |
| server.setKey | string | `""` | Global keys to set (e.g. "nobuildcost,nomap"). Leave empty to skip. |
| server.timezone | string | `"UTC"` | Timezone for the server |
| server.world | string | `"Dedicated"` | World name used for save files |
| service.annotations | object | `{}` | Annotations for the service |
| service.loadBalancerIP | string | `""` | Set specific load balancer IP (depends on cloud provider support) |
| service.loadBalancerSourceRanges | list | `[]` | External source IP ranges allowed to access the server |
| service.nodePorts.game | string | `""` | NodePort for the game port (server.port) |
| service.nodePorts.game1 | string | `""` | NodePort for server.port + 1 |
| service.nodePorts.game2 | string | `""` | NodePort for server.port + 2 |
| service.type | string | `"LoadBalancer"` | Service type |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| startupProbe.failureThreshold | int | 30 (allows up to 5 minutes for initial startup) | Failure threshold |
| startupProbe.initialDelaySeconds | int | `30` | Initial delay seconds |
| startupProbe.periodSeconds | int | `10` | Period seconds |
| startupProbe.timeoutSeconds | int | `5` | Timeout seconds |
| terminationGracePeriodSeconds | int | `120` | Grace period (seconds) for the pod to shut down. Gives the server time to save the world and run an optional shutdown backup before being force-killed. |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)