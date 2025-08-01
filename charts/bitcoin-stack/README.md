# Bitcoin Core Chart

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 27.2](https://img.shields.io/badge/AppVersion-27.2-informational?style=flat-square)

A Helm chart for deploying a full Bitcoin stack: bitcoind, and more to come.

## Prerequisites
Before deploying this chart, ensure your Kubernetes cluster meets the following requirements:

1. Kubernetes 1.19+ – This chart uses features that are supported on Kubernetes 1.19 and above.
2. Helm 3.0+ – Helm 3 is required to manage and deploy this chart.
3. Persistent storage – Bitcoin Core requires significant disk space for blockchain data.

## Installation

### Helm

1. Add the Helm chart repo

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
helm repo update
```

2. Inspect & modify the default values (optional)

```bash
helm show values k8s-charts/bitcoin-stack > custom-values.yaml
```

3. Install the chart

```bash
helm upgrade --install bitcoin-stack k8s-charts/bitcoin-stack --values custom-values.yaml
```

## Using Different Bitcoin Core Images

This chart is designed to work primarily with the `blockstream/bitcoind` image, but it can be adapted to work with other Bitcoin Core images by adjusting the `paths` configuration in your values file:

```yaml
# Example for using a different Bitcoin Core image
image:
  repository: ruimarinho/bitcoin-core
  tag: "27.2"

bitcoind:
  dataDir: "/home/bitcoin/.bitcoin"  # Adjust based on the image's data directory
  configFile: "/home/bitcoin/.bitcoin/bitcoin.conf"  # Adjust based on the image's config path
```

**Note**: While this chart allows for using alternative Bitcoin Core images, compatibility is not guaranteed. Different images may:
- Have different environment variable expectations
- Use different directory structures
- Have different startup parameters

You may need to customize additional settings or even modify the templates for complete compatibility with alternative images.

## Accessing Bitcoin Core

### RPC Access

To access the Bitcoin Core RPC from within the cluster:

```bash
kubectl exec -it sts/bitcoin-stack-bitcoind-0 -- bitcoin-cli -rpccookiefile=/root/.bitcoin/.cookie getblockchaininfo
```

### Port Forwarding

For local access to Bitcoin Core:

```bash
# For RPC access (HTTP)
kubectl port-forward sts/bitcoin-stack-bitcoind-0 8332:8332

# For P2P network access (TCP)
kubectl port-forward sts/bitcoin-stack-bitcoind-0 8333:8333
```

## Storage Considerations

Bitcoin Core requires significant storage for the full blockchain:
- Bitcoin Mainnet: 820+ GB (and growing)
- Bitcoin Testnet: 50+ GB (and growing)

Ensure your persistent volume has adequate capacity. The StatefulSet uses volumeClaimTemplates to provision storage:

```yaml
bitcoind:
  persistence:
    size: 850Gi  # Adjust according to your needs
```

## Advanced Configuration

### Network Types

This chart supports all three Bitcoin network types:
- Mainnet (default): The main Bitcoin network
- Testnet: Test network for development
- Regtest: Local regression testing

To enable testnet:
```yaml
bitcoind:
  testnet: true
```

To enable regtest:
```yaml
bitcoind:
  regtest: true
```

### Storage Optimization

For nodes with limited storage, you can enable pruning:

```yaml
bitcoind:
  pruning: true
  prunesize: 1000  # Size in MiB to target (minimum 550)
```

### Performance Tuning

For better performance, especially on nodes with more resources:

```yaml
bitcoind:
  dbCache: 4096  # Allocate 4GB for database cache
  sync:
    parallelblocks: 16  # Download more blocks in parallel (1-16)
    maxconnections: 125  # Maximum connections to maintain
```

### Advanced Indexing

Enable additional indexes for specific use cases:

```yaml
bitcoind:
  txIndex: true              # Full transaction index
  blockfilterIndex: true     # Compact block filters (BIP158)
  coinstatsIndex: true       # Coinstats index for faster balance calculations
```

### Initial Sync Optimization

For faster initial synchronization, you can use assumevalid:

```yaml
bitcoind:
  sync:
    assumevalid: "00000000000000000008a89e854d57e5667df88f1cdef6fde2fbca1de5b639ad"  # Recent block hash
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | {} | Affinity for pod assignment |
| bitcoind.config | string | "" | bitcoin.conf file content @description -- If provided, this will be mounted as a configuration file. The user and password come from the secret and are passed directly to the command. |
| bitcoind.configFile | string | `"/root/.bitcoin/bitcoin.conf"` | Path where bitcoin.conf should be mounted when using custom config Replaces conf in the configuration file |
| bitcoind.cookieFile | string | `"/root/.bitcoin/.cookie"` | Path where the RPC cookie file should be mounted |
| bitcoind.dataDir | string | `"/root/.bitcoin"` | Directory where Bitcoin Core stores blockchain data Replaces datadir in the configuration file |
| bitcoind.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes for the PVC |
| bitcoind.persistence.annotations | object | {} | Annotations for the PVC |
| bitcoind.persistence.enabled | bool | `true` | Enable persistent storage for blockchain data |
| bitcoind.persistence.existingClaim | string | "" | Use an existing PVC |
| bitcoind.persistence.size | string | `"850Gi"` | Size of the PVC for blockchain data @description -- As of 03.2025, requires 810Gi for full mainnet node |
| bitcoind.persistence.storageClass | string | "" | Storage class for the blockchain PVC @description -- If defined, storageClass: <storageClass> If set to "-", storageClass: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner |
| bitcoind.regtest | int | `0` | Enable regtest mode (local testing) |
| bitcoind.rpc.port | int | `8333` | Port for P2P connections |
| bitcoind.rpc.rpcPort | int | `8332` | Port for RPC interface |
| bitcoind.testnet | int | `0` | Enable testnet instead of mainnet |
| diagnosticMode.args[0] | string | `"infinity"` |  |
| diagnosticMode.command[0] | string | `"sleep"` |  |
| diagnosticMode.enabled | bool | `false` |  |
| electrs.bitcoindDataClaimName | string | `""` | Name of the claim used for bitcoind data when used by other components like electrs |
| electrs.config.bitcoinRpcAddr | string | `"bitcoin-stack-bitcoind:8332"` | Electrs bitcoind RPC address |
| electrs.config.dbDir | string | `"/electrs"` | Electrs data directory |
| electrs.config.electrumRpcAddr | string | `"0.0.0.0:50001"` | Electrs RPC address |
| electrs.config.extraArgs | list | `[]` | Additional command line arguments for electrs |
| electrs.config.httpAddr | string | `"0.0.0.0:3000"` | Electrs HTTP address |
| electrs.config.monitoringAddr | string | `"0.0.0.0:4224"` | Electrs monitoring address |
| electrs.enabled | bool | `false` | Enable electrs component |
| electrs.image | object | `{"pullPolicy":"IfNotPresent","repository":"mempool/electrs","tag":"latest"}` | Electrs image configuration |
| electrs.logTailer.enabled | bool | `false` |  |
| electrs.logTailer.image.repository | string | `"busybox"` |  |
| electrs.logTailer.image.tag | string | `"latest"` |  |
| electrs.logTailer.initialLines | int | `1000` |  |
| electrs.logTailer.pollInterval | int | `5` |  |
| electrs.logTailer.resources.limits.cpu | string | `"100m"` |  |
| electrs.logTailer.resources.limits.memory | string | `"64Mi"` |  |
| electrs.logTailer.resources.requests.cpu | string | `"10m"` |  |
| electrs.logTailer.resources.requests.memory | string | `"32Mi"` |  |
| electrs.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| electrs.persistence.enabled | bool | `false` |  |
| electrs.persistence.existingClaim | string | "" | Use an existing PVC for electrs data |
| electrs.persistence.size | string | `"2Ti"` | Size of the PVC for electrs data @description -- Plan 2TB minimum if not using --lightmode |
| electrs.persistence.storageClass | string | `""` |  |
| electrs.resources | object | `{"limits":{"cpu":"2000m","memory":"16Gi"},"requests":{"cpu":"500m","memory":"8Gi"}}` | Resource requirements for electrs |
| electrs.service | object | `{"httpPort":3000,"monitoringPort":4224,"rpcPort":50001,"type":"ClusterIP"}` | Service configuration for electrs |
| electrs.service.httpPort | int | `3000` | HTTP port for REST API |
| electrs.service.monitoringPort | int | `4224` | Monitoring port for metrics |
| electrs.service.rpcPort | int | `50001` | RPC port for Electrum server clients |
| fullnameOverride | string | `""` | String to fully override bitcoin-core.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"blockstream/bitcoind"` | Docker repository for Bitcoin Core image |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets for private Docker registry |
| ingress.annotations | object | {} | Ingress annotations |
| ingress.className | string | "" | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress for Bitcoin Core RPC |
| ingress.hosts | list | [{ host: bitcoin-rpc.local }] | Ingress hosts configuration |
| ingress.tls | list | [] | Ingress TLS configuration |
| mempool.backend.config | object | `{"backend":"esplora","network":"mainnet"}` | Configuration for mempool backend |
| mempool.backend.config.backend | string | `"esplora"` | Backend type (electrum or esplora) |
| mempool.backend.config.network | string | `"mainnet"` | Network (mainnet, testnet, etc.) |
| mempool.backend.image | object | `{"pullPolicy":"IfNotPresent","repository":"mempool/backend","tag":"v2.5.1"}` | Mempool backend image configuration |
| mempool.backend.resources | object | `{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"200m","memory":"256Mi"}}` | Resource requirements for mempool backend |
| mempool.db | object | `{"auth":{"database":"mempool","password":"mempool","rootPassword":"mempool","username":"mempool"},"image":{"pullPolicy":"IfNotPresent","repository":"mariadb","tag":"10.5.21"},"persistence":{"accessModes":["ReadWriteOnce"],"enabled":false,"size":"10Gi","storageClass":""},"resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"200m","memory":"256Mi"}}}` | Mempool database configuration |
| mempool.db.auth | object | `{"database":"mempool","password":"mempool","rootPassword":"mempool","username":"mempool"}` | Database credentials |
| mempool.db.image | object | `{"pullPolicy":"IfNotPresent","repository":"mariadb","tag":"10.5.21"}` | MariaDB image configuration |
| mempool.db.persistence | object | `{"accessModes":["ReadWriteOnce"],"enabled":false,"size":"10Gi","storageClass":""}` | Persistence for database |
| mempool.db.resources | object | `{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"200m","memory":"256Mi"}}` | Resource requirements for database |
| mempool.enabled | bool | `false` | Enable mempool component |
| mempool.frontend.image | object | `{"pullPolicy":"IfNotPresent","repository":"mempool/frontend","tag":"v2.5.1"}` | Mempool frontend image configuration |
| mempool.frontend.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resource requirements for mempool frontend |
| mempool.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"mempool.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration for mempool frontend |
| mempool.service | object | `{"port":80,"type":"ClusterIP"}` | Service configuration for mempool frontend |
| nameOverride | string | `""` | String to partially override bitcoin-core.fullname template |
| networkPolicy.allowIngressController | bool | `false` | Allow Ingress controller to connect to Bitcoin RPC when using Ingress |
| networkPolicy.enabled | bool | `false` | Enable network policy for Bitcoin Core |
| networkPolicy.ingressControllerNamespaceLabel | string | `"kubernetes.io/metadata.name"` | Label key used to identify the Ingress controller namespace |
| networkPolicy.ingressControllerNamespaceLabelValue | string | `"ingress-nginx"` | Label value used to identify the Ingress controller namespace |
| networkPolicy.p2pAllowFrom | list | [] | Define which pods can access the Bitcoin P2P interface Leave empty to allow all pods to connect to P2P network |
| networkPolicy.rpcAllowFrom | list | [] | Define which pods can access the Bitcoin RPC interface |
| nodeSelector | object | {} | Node selector for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to pods |
| podDisruptionBudget.enabled | bool | `false` | Enable PDB |
| podDisruptionBudget.maxUnavailable | string | `nil` | Maximum unavailable pods |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| podSecurityContext.enabled | bool | `false` | Enable pod security context |
| podSecurityContext.fsGroup | int | `1000` | Group ID to run the pod |
| probes.liveness.enabled | bool | `false` | Enable liveness probe |
| probes.liveness.failureThreshold | int | `3` | Failure threshold |
| probes.liveness.initialDelaySeconds | int | `60` | Initial delay seconds |
| probes.liveness.periodSeconds | int | `30` | Period seconds |
| probes.liveness.timeoutSeconds | int | `5` | Timeout seconds |
| probes.readiness.enabled | bool | `false` | Enable readiness probe |
| probes.readiness.failureThreshold | int | `3` | Failure threshold |
| probes.readiness.initialDelaySeconds | int | `30` | Initial delay seconds |
| probes.readiness.periodSeconds | int | `10` | Period seconds |
| probes.readiness.successThreshold | int | `1` | Success threshold |
| probes.readiness.timeoutSeconds | int | `5` | Timeout seconds |
| probes.startup.enabled | bool | `false` | Enable startup probe |
| probes.startup.failureThreshold | int | `30` | Failure threshold |
| probes.startup.initialDelaySeconds | int | `30` | Initial delay seconds |
| probes.startup.periodSeconds | int | `10` | Period seconds |
| probes.startup.timeoutSeconds | int | `5` | Timeout seconds |
| resources | object | `{}` | Resource requests and limits |
| securityContext.enabled | bool | `false` | Enable security context |
| securityContext.readOnlyRootFilesystem | bool | `false` | Allow write access to root filesystem |
| securityContext.runAsNonRoot | bool | `true` | Ensures container is not run as root |
| securityContext.runAsUser | int | `1000` | User ID to run the container |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | "" | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | [] | Tolerations for pod assignment |
| topologySpreadConstraints | list | `[]` | Topology spread constraints for pod distribution |
| volumePermissions.enabled | bool | `false` | Enable an init container to set volume permissions |
| volumePermissions.image | string | `"busybox"` | Image to use for volume permissions init container |
| volumePermissions.pullPolicy | string | `"IfNotPresent"` | Image pull policy for init container |
| volumePermissions.securityContext | object | `{"enabled":true,"runAsUser":0}` | Security context for volume permissions init container |
