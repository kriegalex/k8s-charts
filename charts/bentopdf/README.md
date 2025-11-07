# BentoPDF Chart
===========

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.1.5](https://img.shields.io/badge/AppVersion-1.1.5-informational?style=flat-square)

A Helm chart for BentoPDF - PDF manipulation service using BentoML

## Overview

BentoPDF is a PDF manipulation service built with BentoML. This Helm chart deploys BentoPDF along with a Gotenberg sidecar container for PDF conversion capabilities.

## Installation

### Installation via Helm

1. Add the Helm chart repo

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
```

2. Inspect & modify the default values (optional)

```bash
helm show values k8s-charts/bentopdf > custom-values.yaml
```

3. Install the chart

```bash
helm upgrade --install bentopdf k8s-charts/bentopdf -f custom-values.yaml
```

## Features

- **BentoPDF Service**: PDF manipulation and processing
- **Gotenberg Sidecar**: Optional Gotenberg container for PDF conversion
- **Ingress Support**: Optional ingress with automatic TLS configuration
- **Horizontal Pod Autoscaling**: Optional HPA configuration
- **Persistent Storage**: Optional persistent storage for temporary files
- **Security Hardened**: Runs as non-root user (UID/GID 2000) following BentoPDF security best practices

## Security

This chart follows the official BentoPDF security recommendations:

- **Non-Root Execution**: Container runs as user ID 2000 (non-root)
- **Port 8080**: Uses high port number to avoid requiring root privileges
- **nginx-unprivileged**: Based on nginx-unprivileged image for enhanced security
- **Principle of Least Privilege**: Minimal container privileges with dropped capabilities
- **No Privilege Escalation**: `allowPrivilegeEscalation` is set to false

For more information about BentoPDF security features, see the [official security documentation](https://github.com/alam00000/bentopdf/blob/main/SECURITY.md).

## License

[MIT](../../LICENSE)

## Values

The following table lists the configurable parameters of the BentoPDF chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.logLevel | string | `"INFO"` | Log level: DEBUG, INFO, WARNING, ERROR |
| config.workers | int | `1` | Number of workers |
| fullnameOverride | string | `""` | String to fully override bentopdf.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"bentopdf/bentopdf-simple"` | Docker image repository for BentoPDF (uses nginx-unprivileged for enhanced security) |
| image.tag | string | "" | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets for private Docker registry |
| ingress.annotations | object | `{}` | Additional ingress annotations @example annotations:   cert-manager.io/cluster-issuer: letsencrypt-prod |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress resource |
| ingress.tls.enabled | bool | `false` | Enable TLS for ingress |
| ingress.tls.secretName | string | "<release-name>-bentopdf-ingress-lets-encrypt" | Secret name for TLS certificate |
| ingress.url | string | `""` | The URL for the ingress endpoint to point to the BentoPDF instance |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/healthz"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` | String to partially override bentopdf.fullname template |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the persistent volume |
| persistence.enabled | bool | `false` | Enable persistent storage |
| persistence.existingClaim | string | "" | Use an existing PVC |
| persistence.mountPath | string | `"/tmp/bentopdf"` | Mount path for persistent storage |
| persistence.size | string | `"10Gi"` | Size of the persistent volume |
| persistence.storageClass | string | "" | Storage class for the PVC |
| podAnnotations | object | `{}` | Annotations to add to pods |
| podSecurityContext.fsGroup | int | `101` | Group ID for filesystem access |
| podSecurityContext.runAsGroup | int | `101` | Group ID to run the pod |
| podSecurityContext.runAsNonRoot | bool | `true` | Run container as non-root user |
| podSecurityContext.runAsUser | int | `101` | User ID to run the pod |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicaCount | int | `1` | Number of pod replicas |
| resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource limits and requests for BentoPDF |
| securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` | Allow write access to root filesystem |
| service.annotations | object | `{}` | Additional annotations for the service |
| service.port | int | `8080` | Kubernetes Service port |
| service.targetPort | int | `8080` | Container target port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | If the service account token should be auto mounted |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | "" | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
