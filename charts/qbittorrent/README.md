# QBittorrent Chart

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: legacy-4.3.9](https://img.shields.io/badge/AppVersion-legacy--4.3.9-informational?style=flat-square)

A Helm chart for deploying a QBittorrent client that uses a wireguard VPN tunnel.

## Important note

**By default, this chart uses the 4.3.9 version of qBittorrent, known to be stable.**

## Breaking Changes in v2.0.0

**⚠️ Important:** Version 2.0.0 introduces breaking changes to the VPN configuration structure.

### What Changed

VPN configuration has been restructured with dedicated subsections for PIA and WireGuard:

**Old (v1.x):**
```yaml
vpn:
  enabled: true
  provider: pia
  existingSecret: ""
  config: ""
```

**New (v2.0.0):**
```yaml
vpn:
  pia:
    enabled: false
    existingSecret: ""
  wireguard:
    enabled: false
    config: ""
```

### Key Changes

1. **Removed `vpn.enabled`** - Use `vpn.pia.enabled` or `vpn.wireguard.enabled` instead
2. **Removed `vpn.provider`** - No longer needed; use dedicated subsections
3. **Moved PIA credentials** from `vpn.existingSecret` to `vpn.pia.existingSecret`
4. **Moved WireGuard config** from `vpn.config` to `vpn.wireguard.config`

### Why This Change?

To clearly separate two mutually exclusive VPN types:

1. **PIA VPN** (`vpn.pia.*`): Private Internet Access provider with username/password
2. **Custom WireGuard** (`vpn.wireguard.*`): Custom WireGuard server configuration

Each now has its own `enabled` toggle, making the configuration clearer and preventing confusion.

### Migration Guide

**If you were using PIA (v1.x):**
```yaml
# Before
vpn:
  enabled: true
  provider: pia
  existingSecret: my-pia-secret
  existingKeys:
    usernameKey: username
    passwordKey: password
```

```yaml
# After
vpn:
  pia:
    enabled: true
    existingSecret: my-pia-secret
    existingKeys:
      usernameKey: username
      passwordKey: password
```

**If you were using custom WireGuard (v1.x):**
```yaml
# Before
vpn:
  enabled: true
  config: |
    [Interface]
    PrivateKey = MY-KEY
    ...
```

```yaml
# After
vpn:
  wireguard:
    enabled: true
    config: |
      [Interface]
      PrivateKey = MY-KEY
      ...
```

## Prerequisites
Before deploying this chart, ensure your Kubernetes cluster meets the following requirements:

1. Kubernetes 1.19+ – This chart uses features that are supported on Kubernetes 1.19 and above.
3. Helm 3.0+ – Helm 3 is required to manage and deploy this chart.
3. WireGuard Kernel Module – WireGuard must be available on all nodes in your cluster.

## Installation

### Allow unsafe sysctl

You need to allow two unsafe sysctl to be set by this chart. To do so, we must modify the existing kubelet configuration on the target worker nodes.

```console
cat <<EOF | sudo tee -a /var/lib/kubelet/config.yaml

# Add or update the following section:
allowedUnsafeSysctls:
  - "net.ipv4.conf.all.src_valid_mark"
  - "net.ipv6.conf.all.disable_ipv6"
EOF
```

Restart the kubelet service:

```console
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### Helm

1. Add the Helm chart repo

```bash
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
helm repo update
```

2. Inspect & modify the default values (optional)

```bash
helm show values k8s-charts/qbittorrent > custom-values.yaml
```

3. Install the chart

```bash
helm upgrade --install qbit k8s-charts/qbittorrent --values custom-values.yaml
```

## QBittorrent login

The login is `admin`. The password is visible in the logs of the qbittorent app the first time you start it:

```
kubectl logs qbit-qbittorrent-POD_NAME
```

Replace POD_NAME by the name of your pod (`kubectl get pods`).

## Port Forwarding

The port forwarding should be handled automatically by the docker image, if the correct environment variables have been set.

You can check it in the logs:

```console
kubectl logs qbit-qbittorrent-POD_NAME
```

Expected result:
```console
******** Information ********
To control qBittorrent, access the WebUI at: http://localhost:8080

[INF] [] [VPN] Forwarded port is [PORT].
[INF] [] [QBITTORRENT] Updated forwarded port to [PORT].
```

## VPN Configuration

This chart supports two mutually exclusive VPN types. **Do not enable both at the same time.**

### 1. PIA VPN (Private Internet Access)

Enable PIA VPN by setting `vpn.pia.enabled: true`. This requires username and password authentication:

```yaml
vpn:
  pia:
    enabled: true
    existingSecret: my-pia-credentials  # Secret with 'username' and 'password' keys
    existingKeys:
      usernameKey: username
      passwordKey: password
```

**Note:** PIA credentials are completely separate from WireGuard configuration files.

### 2. Custom WireGuard VPN

Enable custom WireGuard VPN by setting `vpn.wireguard.enabled: true`. For custom WireGuard VPN setups, provide the WireGuard configuration file (`wg0.conf`). This chart supports three methods with the following precedence:

#### Option A: Existing Secret (Recommended) ⭐

**Best practice for production environments.** Store your WireGuard configuration in a Kubernetes Secret, as it contains sensitive private keys.

```bash
# Create a secret with your WireGuard config
kubectl create secret generic my-wg-secret --from-file=wg0.conf=/path/to/wg0.conf

# Reference it in values.yaml
vpn:
  wireguard:
    enabled: true
    existingSecret: my-wg-secret
    secretKey: wg0.conf  # optional, defaults to "wg0.conf"
```

This approach:
- ✅ Keeps private keys secure
- ✅ Works with external secret managers (External Secrets Operator, Sealed Secrets, etc.)
- ✅ Follows Kubernetes security best practices

#### Option B: Existing ConfigMap (Alternative)

**Not recommended for production.** Use only for testing or non-sensitive environments.

```bash
# Create a configmap with your WireGuard config
kubectl create configmap my-wg-config --from-file=wg0.conf=/path/to/wg0.conf

# Reference it in values.yaml
vpn:
  wireguard:
    enabled: true
    existingConfigMap: my-wg-config
    configMapKey: wg0.conf  # optional, defaults to "wg0.conf"
```

⚠️ **Warning:** ConfigMaps store data in plain text and are easier to access. Not recommended for production use.

#### Option C: Inline Configuration

**Least secure.** Configuration is stored directly in values.yaml or visible in Helm releases.

```yaml
vpn:
  wireguard:
    enabled: true
    config: |
      [Interface]
      PrivateKey = YOUR-PRIVATE-KEY
      Address = 10.0.0.1/24

      [Peer]
      PublicKey = PEER-PUBLIC-KEY
      AllowedIPs = 0.0.0.0/0
```

⚠️ **Warning:** Private keys will be visible in your values files and Helm release history.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Pod affinity/anti-affinity settings |
| commonLabels | object | {} | Common labels for all resources created by this chart |
| env.PGID | int | `1000` | The group ID (GID) for running the container Ensures files are created with the correct group ownership |
| env.PRIVOXY_ENABLED | bool | `false` | Enable Privoxy HTTP proxy |
| env.PUID | int | `1000` | The user ID (UID) for running the container Ensures files are created with the correct user ownership |
| env.TZ | string | "Etc/UTC" | Timezone setting |
| env.UMASK | int | `2` | The file permission mask Controls default file and directory permissions 002 means new files will have 664 (-rw-rw-r--) and directories 775 (drwxrwxr-x) |
| env.UNBOUND_ENABLED | bool | `false` | Enable Unbound DNS resolver |
| env.VPN_AUTO_PORT_FORWARD | bool | `true` | Enables automatic port forwarding through the VPN This is often necessary for torrenting to allow incoming connections |
| env.VPN_AUTO_PORT_FORWARD_TO_PORTS | string | "" | Specific ports to forward if VPN_AUTO_PORT_FORWARD is enabled Leave empty to let the VPN provider choose |
| env.VPN_CONF | string | `"wg0"` | The VPN configuration file to use Typically set to 'wg0' for WireGuard or 'openvpn' for OpenVPN configurations |
| env.VPN_EXPOSE_PORTS_ON_LAN | string | "" | Ports to be exposed to the LAN network Leave empty to disable or specify ports if needed |
| env.VPN_FIREWALL_TYPE | string | `"auto"` | Configures the type of firewall to use with the VPN 'auto' lets the container decide based on the VPN type |
| env.VPN_HEALTHCHECK_ENABLED | bool | `true` | Enables health checks to ensure the VPN connection is active If the VPN connection drops, the container may restart or stop |
| env.VPN_KEEP_LOCAL_DNS | bool | `false` | Keeps the local DNS settings when the VPN is connected Set to 'false' to use the DNS provided by the VPN |
| env.VPN_LAN_LEAK_ENABLED | bool | `false` | Determines if LAN traffic should bypass the VPN Set to 'false' to prevent local network traffic from leaking outside the VPN tunnel |
| env.VPN_LAN_NETWORK | string | `"192.168.1.0/24"` | The LAN network IP range that should bypass the VPN Useful for allowing local network access while the VPN is active |
| env.VPN_PIA_DIP_TOKEN | string | `"no"` | PIA Dedicated IP token Set to 'no' if not using a dedicated IP with PIA |
| env.VPN_PIA_PASS | string | "" | Private Internet Access (PIA) password Overrides vpn.pia.existingSecret if provided |
| env.VPN_PIA_PORT_FORWARD_PERSIST | bool | `false` | If true, persists the port forwarding setting across sessions Useful if consistent port forwarding is required |
| env.VPN_PIA_PREFERRED_REGION | string | "" | Preferred region for the PIA VPN Leave empty to let PIA choose the optimal server automatically |
| env.VPN_PIA_USER | string | "" | Private Internet Access (PIA) username Overrides vpn.pia.existingSecret if provided |
| env.WEBUI_PORTS | string | "8080/tcp,8080/udp" | Ports for the qBittorrent Web UI |
| fullnameOverride | string | `""` | Override the full name of the chart |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/hotio/qbittorrent"` | Docker image repository for qBittorrent |
| image.tag | string | `""` | Docker image tag |
| ingress.annotations | object | {} | Additional annotations for the ingress resource @example annotations:   kubernetes.io/ingress.class: nginx   kubernetes.io/tls-acme: "true" |
| ingress.className | string | `"nginx"` | The ingress class that should be used |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.hosts | list | "chart-example.local" | Host configuration for the ingress |
| ingress.tls | list | [] | TLS configuration for the ingress @example tls:   - secretName: chart-example-tls     hosts:       - chart-example.local |
| nameOverride | string | `""` | Override the name of the chart |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode for the configuration PVC |
| persistence.config.enabled | bool | `false` | Enable persistent storage for qBittorrent configuration |
| persistence.config.size | string | `"1Gi"` | Size of the configuration PVC |
| persistence.data.accessMode | string | `"ReadWriteOnce"` | Access mode for the data PVC |
| persistence.data.enabled | bool | `false` | Enable persistent storage for downloads |
| persistence.data.size | string | `"500Gi"` | Size of the data PVC |
| replicaCount | int | `1` | Number of replicas to be deployed |
| resources | object | {} | Resource requests and limits for the qBittorrent container @example resources:   limits:     cpu: 100m     memory: 128Mi   requests:     cpu: 100m     memory: 128Mi |
| service.port | int | `8080` | Port for the qBittorrent WebUI |
| service.type | string | `"ClusterIP"` | Service type |
| vpn.pia.enabled | bool | `false` | Enable PIA VPN (sets VPN_ENABLED=true and VPN_PROVIDER=pia) |
| vpn.pia.existingKeys | object | `{"passwordKey":"","usernameKey":""}` | Names of keys in existing secret to use for PIA credentials |
| vpn.pia.existingKeys.passwordKey | string | "" | Password key in the secret (same as VPN_PIA_PASS env) |
| vpn.pia.existingKeys.usernameKey | string | "" | Username key in the secret (same as VPN_PIA_USER env) |
| vpn.pia.existingSecret | string | "" | Name of existing secret to use for PIA VPN credentials (username/password) |
| vpn.wireguard.config | string | "" | Inline WireGuard configuration to be copied to /config/wireguard/wg0.conf @example config: |   [Interface]   PrivateKey = MY-PRIVATE-KEY   Address = 10.0.0.1/24   ListenPort = 51820    [Peer]   PublicKey = PEER-PUBLIC-KEY   AllowedIPs = 0.0.0.0/0 |
| vpn.wireguard.configMapKey | string | "wg0.conf" | Key in the existing ConfigMap that contains the wg0.conf data |
| vpn.wireguard.enabled | bool | `false` | Enable custom WireGuard VPN (sets VPN_ENABLED=true) |
| vpn.wireguard.existingConfigMap | string | "" | Name of existing ConfigMap containing WireGuard wg0.conf file (not recommended for production) Only used if existingSecret is not set. Takes precedence over inline config |
| vpn.wireguard.existingSecret | string | "" | Name of existing Secret containing WireGuard wg0.conf file (recommended for production) Takes precedence over existingConfigMap and inline config |
| vpn.wireguard.secretKey | string | "wg0.conf" | Key in the existing Secret that contains the wg0.conf data |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
