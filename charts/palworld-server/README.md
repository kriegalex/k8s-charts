# Palworld Server Helm Chart

![Version: 1.0.6](https://img.shields.io/badge/Version-1.0.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.2.3](https://img.shields.io/badge/AppVersion-v1.2.3-informational?style=flat-square)

This Helm chart deploys a Palworld dedicated game server on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.29+
- Helm 3.16.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Important Notes

It is recommended to set some minimal resources for your server:

```
resources:
  limits:
    memory: 32Gi
  requests:
    cpu: 4000m
    memory: 8Gi
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraEnv | list | [] | Additional environment variables @example extraEnv:   - name: TZ     value: "UTC" |
| fullnameOverride | string | `""` | Override the full name of the chart |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"thijsvanloef/palworld-server-docker"` | Docker image repository |
| image.tag | string | "" (defaults to Chart.AppVersion) | Docker image tag |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| livenessProbe.failureThreshold | int | 6 (allows up to 2 minutes for recovery) | Failure threshold |
| livenessProbe.initialDelaySeconds | int | `60` | Initial delay seconds |
| livenessProbe.periodSeconds | int | `20` | Period seconds |
| livenessProbe.timeoutSeconds | int | `5` | Timeout seconds |
| nameOverride | string | `""` | Override the name of the chart |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC |
| persistence.annotations | object | {} | Additional PVC annotations |
| persistence.enabled | bool | `true` | Enable persistent storage for game data |
| persistence.existingClaim | string | "" | Use an existing PVC |
| persistence.size | string | `"20Gi"` | Size of the PVC for game data and saves |
| persistence.storageClassName | string | "" | Storage class for the game data PVC |
| podSecurityContext | object | `{"fsGroup":1000}` | Security context for the pod |
| podSecurityContext.fsGroup | int | `1000` | Group ID for filesystem access |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | 20 (allows up to 5 minutes for readiness) | Failure threshold |
| readinessProbe.initialDelaySeconds | int | `60` | Initial delay seconds |
| readinessProbe.periodSeconds | int | `15` | Period seconds |
| readinessProbe.timeoutSeconds | int | `5` | Timeout seconds |
| resources | object | {} | Container resource requests and limits |
| securityContext.capabilities | object | `{"drop":["ALL"]}` | Security capabilities to drop |
| securityContext.runAsGroup | int | `1000` | Group ID to run the container |
| securityContext.runAsNonRoot | bool | `true` | Run container as non-root user |
| securityContext.runAsUser | int | `1000` | User ID to run the container |
| server.adminPassword | string | "changemeAdmin" | Admin password for RCON access |
| server.community | bool | `false` | Enable to show in community servers tab WARNING: USE WITH SERVER_PASSWORD! |
| server.description | string | `"Palworld Dedicated Server powered by Kubernetes"` | Server description displayed in the server browser |
| server.multithreading | bool | `true` | Enable multithreading for better performance |
| server.name | string | `"Palworld Server"` | Server name displayed in the server browser |
| server.password | string | `"changeme"` | Server password Optional but recommended for security |
| server.players | int | `16` | Maximum number of players allowed on the server |
| server.port | int | `8211` | Server port (must match service port) |
| server.rconEnabled | bool | `true` | Enable RCON for server administration |
| server.rconPort | int | `25575` | RCON port for admin commands |
| server.timezone | string | `"UTC"` | Server timezone |
| service.annotations | object | {} | Additional service annotations |
| service.nodePort | string | "" | Specify a nodePort value if using NodePort service type |
| service.port | int | `8211` | TCP port for game traffic |
| service.portUDP | int | `8211` | UDP port for game traffic (must match TCP port) |
| service.type | string | `"LoadBalancer"` | Service type (LoadBalancer recommended for game server access) |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | "" | The name of the service account to use |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| startupProbe.failureThreshold | int | 30 (allows up to 5 minutes for initial startup) | Failure threshold |
| startupProbe.initialDelaySeconds | int | `30` | Initial delay seconds |
| startupProbe.periodSeconds | int | `10` | Period seconds |
| startupProbe.timeoutSeconds | int | `5` | Timeout seconds |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
