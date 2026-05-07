# nostr-strfry

![Version: 1.2.0](https://img.shields.io/badge/Version-1.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.1.0](https://img.shields.io/badge/AppVersion-1.1.0-informational?style=flat-square)

A Helm chart for deploying a Nostr strfry relay

## Introduction

This Helm chart deploys a [strfry](https://github.com/hoytech/strfry) Nostr relay on a Kubernetes cluster. Strfry is a high-performance, resource-efficient Nostr relay implementation written in C++, designed to handle high traffic loads while maintaining efficient resource usage.

## Prerequisites

- Kubernetes 1.29+
- Helm 3.16+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `nostr-strfry`:

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
helm repo update
helm install nostr-strfry k8s-charts/nostr-strfry
```

## Uninstalling the Chart

To uninstall/delete the `nostr-strfry` deployment:

```bash
helm delete nostr-strfry
```

## Configuration

The following table lists the configurable parameters for the nostr-strfry chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.db | string | `"/app/strfry-db"` | Directory that contains the strfry LMDB database |
| config.dbParams.mapsize | string | `"10995116277760"` | Size of mmap() to use when loading LMDB (default is 10TB) |
| config.dbParams.maxreaders | int | `256` | Maximum number of threads/processes that can simultaneously have LMDB transactions open |
| config.dbParams.noReadAhead | bool | `false` | Disables read-ahead when accessing the LMDB mapping |
| config.events.ephemeralEventsLifetimeSeconds | int | `300` | Ephemeral events will be deleted from the DB when older than this (in seconds) |
| config.events.maxEventSize | string | `"65536"` | Maximum size of normalised JSON, in bytes |
| config.events.maxNumTags | int | `2000` | Maximum number of tags allowed |
| config.events.maxTagValSize | int | `1024` | Maximum size for tag values, in bytes |
| config.events.rejectEphemeralEventsOlderThanSeconds | int | `60` | Ephemeral events older than this (in seconds) will be rejected |
| config.events.rejectEventsNewerThanSeconds | int | `900` | Events newer than this (in seconds) will be rejected |
| config.events.rejectEventsOlderThanSeconds | string | `"94608000"` | Events older than this (in seconds) will be rejected |
| config.relay.auth.enabled | bool | `false` | Enable NIP-42 authentication. When true, `serviceUrl` must be set. |
| config.relay.auth.serviceUrl | string | `""` | External relay URL required for NIP-42 validation (e.g. wss://relay.example.com) |
| config.relay.autoPingSeconds | int | `55` | Websocket-level PING message frequency (seconds) |
| config.relay.bind | string | `"0.0.0.0"` | Interface to listen on (Use 0.0.0.0 for k3s) |
| config.relay.compression.enabled | bool | `true` | Enable permessage-deflate compression if supported by client |
| config.relay.compression.slidingWindow | bool | `true` | Maintain a sliding window buffer for each connection |
| config.relay.enableTcpKeepalive | bool | `false` | Enable TCP keep-alive to detect dropped connections |
| config.relay.filterValidation.allowedKinds | string | `""` | Comma-separated list of allowed kinds (empty = all) |
| config.relay.filterValidation.enabled | bool | `false` | Enable REQ filter validation |
| config.relay.filterValidation.maxFiltersPerReq | int | `3` | Maximum number of filters allowed per REQ |
| config.relay.filterValidation.maxKindsPerFilter | int | `3` | Maximum number of kinds allowed per filter |
| config.relay.filterValidation.minFiltersPerReq | int | `1` | Minimum number of filters required per REQ |
| config.relay.filterValidation.requireAuthorOrTag | bool | `false` | Require filters to contain an author or tag constraint |
| config.relay.info.banner | string | `""` | NIP-11: Banner image URL |
| config.relay.info.contact | string | `""` | NIP-11: Alternative administrative contact |
| config.relay.info.description | string | `"This is a strfry instance."` | NIP-11: Detailed information about relay |
| config.relay.info.icon | string | `""` | NIP-11: URL pointing to an image to be used as an icon for the relay |
| config.relay.info.name | string | `"strfry default"` | NIP-11: Name of this server (< 30 characters) |
| config.relay.info.nips | string | `""` | List of supported NIPs as JSON array, or empty string to use default |
| config.relay.info.privacy | string | `""` | NIP-11: Privacy policy URL |
| config.relay.info.pubkey | string | `""` | NIP-11: Administrative nostr pubkey, for contact purposes |
| config.relay.info.self | string | `""` | NIP-11: Relay's own pubkey (npub or hex format) |
| config.relay.info.terms | string | `""` | NIP-11: Terms of service URL |
| config.relay.logging.dbScanPerf | bool | `false` | Log performance metrics for initial REQ database scans |
| config.relay.logging.dumpInAll | bool | `false` | Dump all incoming messages |
| config.relay.logging.dumpInEvents | bool | `false` | Dump all incoming EVENT messages |
| config.relay.logging.dumpInReqs | bool | `false` | Dump all incoming REQ/CLOSE messages |
| config.relay.logging.invalidEvents | bool | `true` | Log reason for invalid event rejection |
| config.relay.maxFilterLimit | int | `500` | Maximum records that can be returned per filter |
| config.relay.maxFilterLimitCount | string | `"1000000"` | Maximum records that can be returned per filter for NIP-45 COUNT (0 = disable) |
| config.relay.maxReqFilterSize | int | `200` | Maximum number of filters allowed in a REQ |
| config.relay.maxSubsPerConnection | int | `200` | Maximum number of subscriptions a connection can have open |
| config.relay.maxWebsocketPayloadSize | string | `"131072"` | Maximum accepted incoming websocket frame size (bytes) |
| config.relay.negentropy.enabled | bool | `true` | Support negentropy protocol messages |
| config.relay.negentropy.maxSyncEvents | string | `"1000000"` | Maximum records that sync will process before returning an error |
| config.relay.nofiles | string | `"1000000"` | OS-limit on maximum number of open files/sockets (if 0, don't attempt to set) |
| config.relay.numThreads.ingester | int | `3` | Ingester threads: route incoming requests, validate events/sigs |
| config.relay.numThreads.negentropy | int | `2` | negentropy threads: Handle negentropy protocol messages |
| config.relay.numThreads.reqMonitor | int | `3` | reqMonitor threads: Handle filtering of new events |
| config.relay.numThreads.reqWorker | int | `3` | reqWorker threads: Handle initial DB scan for events |
| config.relay.port | int | `7777` | Port to open for the nostr websocket protocol |
| config.relay.queryTimesliceBudgetMicroseconds | string | `"10000"` | Uninterrupted CPU time for a REQ query during DB scan (microseconds) |
| config.relay.realIpHeader | string | `""` | HTTP header that contains the client's real IP, before reverse proxying (must be all lower-case) |
| config.relay.writePolicy.plugin | string | `""` | Path to an executable script that implements the writePolicy plugin logic |
| config.relay.writePolicy.timeoutSeconds | int | `10` | Timeout in seconds for the writePolicy plugin response |
| fullnameOverride | string | `""` | String to fully override nostr-relay.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Nostr relay Docker image pull policy |
| image.repository | string | `"dockurr/strfry"` | Nostr strfry Docker image repository |
| image.tag | string | `""` | Overrides the image tag. Default is the chart appVersion |
| imagePullSecrets | list | `[]` | Specify imagePullSecrets if your Docker repository requires authentication |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress resource |
| ingress.hosts | list | [{ host: nostr.k3s.home }] | List of ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| nameOverride | string | `""` | String to partially override nostr-relay.fullname template |
| nip05.enabled | bool | `false` | Enable NIP-05 verification service |
| nip05.identities | string | `nil` | NIP-05 identities mapping usernames to public keys |
| nip05.image.pullPolicy | string | `"IfNotPresent"` | NIP-05 server Docker image pull policy |
| nip05.image.repository | string | `"nginx"` | NIP-05 server Docker image repository |
| nip05.image.tag | string | `"alpine"` | Overrides the image tag |
| nip05.relays | string | `nil` | NIP-05 identities mapping user public keys to relays |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode for the persistent volume |
| persistence.enabled | bool | `true` | Enable persistent storage for the database |
| persistence.size | string | `"10Gi"` | Size of the persistent volume |
| persistence.storageClass | string | `""` | StorageClass name. If empty, uses the default provisioner. |
| podAnnotations | object | `{}` | Annotations to be added to the pod |
| podSecurityContext.fsGroup | int | `1000` |  |
| replicaCount | int | `1` | Number of nostr-relay replicas |
| resources | object | `{}` | Resource limits and requests for the relay |
| securityContext.runAsGroup | int | `1000` | Group ID to run the container |
| securityContext.runAsNonRoot | bool | `true` | Run container as non-root user |
| securityContext.runAsUser | int | `1000` | User ID to run the container |
| service.port | int | `7777` | Kubernetes Service port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| terminationGracePeriodSeconds | int | `120` | Grace period for pod termination in seconds (corresponds to stop_grace_period) |

## Persistence

This chart mounts a Persistent Volume for the strfry database. The volume is created using dynamic volume provisioning. If you want to disable this (and instead use an emptyDir volume), set `persistence.enabled` to `false`.

For production use, it's recommended to:
- Use a reliable storage class
- Set an appropriate volume size (default is 10Gi)
- Consider backup strategies for your database

## Ingress and Reverse Proxy

This chart includes support for Ingress resources. If you have an Ingress controller installed on your cluster, such as [nginx-ingress](https://kubernetes.github.io/ingress-nginx/) or [traefik](https://traefik.io/), you can utilize the ingress controller to serve your Nostr relay.

For proper WebSocket support in an ingress configuration, you may need to add specific annotations. For example, with NGINX:

```yaml
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-body-size: "64m"
  hosts:
    - host: relay.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: relay-tls
      hosts:
        - relay.example.com
```

## NIP Support

Strfry supports multiple NIPs (Nostr Implementation Possibilities). You can specify the supported NIPs in your values file:

```yaml
config:
  relay:
    info:
      nips: "[1, 2, 4, 9, 11, 22, 28, 40, 70, 77]"
```

## NIP-05 Support

This chart includes built-in support for NIP-05 (.well-known/nostr.json) verification. To enable it:

```yaml
nip05:
  enabled: true
  identities:
    username1: "hex_public_key1"
    username2: "hex_public_key2"
```

When enabled, the chart deploys a small nginx container to serve the necessary static files, and updates the ingress to route `.well-known` paths to this service. Users can then verify themselves using NIP-05 identifiers like `username1@yourdomain.com`.

### Configuring NIP-05 Identities

Add usernames and their corresponding public keys to the `nip05.identities` map in your values file:

```yaml
nip05:
  enabled: true
  identities:
    alice: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    bob: "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210"
```

## Using with Kubernetes

Once your relay is deployed, you can access it using the service endpoint. The default configuration creates a ClusterIP service, which means it's only accessible within the cluster.

### Accessing the Relay

1. For internal cluster access:
   ```
   ws://RELEASE-NAME-nostr-strfry.NAMESPACE.svc.cluster.local:7777
   ```

2. To access from your local machine:
   ```bash
   kubectl port-forward --namespace NAMESPACE svc/RELEASE-NAME-nostr-strfry 7777:7777
   ```
   Then connect to `ws://localhost:7777`

3. If you enabled Ingress, use the domain you specified.

### Checking Logs

To view the logs of your relay:
```bash
kubectl logs -f deployment/RELEASE-NAME-nostr-strfry -n NAMESPACE
```

## Notes on Production Use

For production deployments, consider:

1. Using a specific image tag rather than `latest`
2. Setting appropriate resource limits and requests
3. Enabling TLS via Ingress or another method
4. Setting up proper monitoring and backup strategies for the database
5. Configuring appropriate parameters for your expected load:
   - `maxWebsocketPayloadSize`
   - `maxFilterLimit`
   - `maxSubsPerConnection`
   - Thread counts based on your server capacity
6. Setting up a proper NIP-11 info section with your relay information
7. Enabling and configuring the Negentropy protocol for efficient relay synchronization

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
