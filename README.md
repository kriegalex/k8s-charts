# Homelab Helm Charts

A collection of Helm charts for self-hosted applications optimized for homelab environments.

## Overview

This repository contains Helm charts designed for easy deployment of popular self-hosted applications in Kubernetes environments. These charts are tailored for homelab setups but can also be used in production environments with appropriate modifications.

## Features

- Easy-to-configure values with sensible defaults
- Comprehensive documentation for each chart
- Optimized for resource-constrained environments
- Support for persistent storage
- Ingress configuration included

## Available Charts

| Chart            | Description                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------ |
| actual-budget    | A self-hosted budgeting application                                                        |
| bentopdf         | PDF manipulation service using BentoML                                                     |
| bitcoin-stack    | A full Bitcoin stack (bitcoind, and more to come)                                          |
| clonarr          | Visual TRaSH-Guides sync tool for Radarr and Sonarr                                        |
| deltabadger      | Auto-DCA bot for crypto investments                                                        |
| enshrouded-server| Dedicated server for Enshrouded                                                            |
| jellyfin         | Media system that puts you in control of your media                                        |
| nostr-rs-relay   | A Nostr relay (nostr-rs-relay)                                                             |
| nostr-strfry     | A Nostr relay (strfry)                                                                     |
| palworld-server  | Dedicated server for Palworld                                                              |
| qbittorrent      | BitTorrent client with built-in WireGuard VPN tunnel                                       |
| valheim-server   | Dedicated server for Valheim                                                               |

## Getting Started

### Prerequisites

- Kubernetes cluster 1.29+
- Helm 3.16.0+

### Repository Setup

To add the Helm repository, run:

```
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/
helm repo update
```

### Installing Charts

To install a chart from this repository:

```
helm install my-jellyfin k8s-charts/jellyfin
```

Or with custom values:

```
helm install my-jellyfin k8s-charts/jellyfin -f my-values.yaml
```

## Chart Documentation

Each chart includes detailed documentation on available configuration options:

- [**Actual Budget**](charts/actual-budget/README.md)
- [**BentoPDF**](charts/bentopdf/README.md)
- [**Bitcoin Stack**](charts/bitcoin-stack/README.md)
- [**Clonarr**](charts/clonarr/README.md)
- [**Deltabadger**](charts/deltabadger/README.md)
- [**Enshrouded**](charts/enshrouded-server/README.md)
- [**Jellyfin**](charts/jellyfin/README.md)
- [**Nostr RS Relay**](charts/nostr-rs-relay/README.md)
- [**Nostr strfry**](charts/nostr-strfry/README.md)
- [**Palworld**](charts/palworld-server/README.md)
- [**qBittorrent**](charts/qbittorrent/README.md)
- [**Valheim**](charts/valheim-server/README.md)

## Configuration

### Common Configuration Options

Most charts support these common configuration patterns:

#### Persistence

```
persistence:
  config:
    enabled: true
    size: 1Gi
    storageClassName: local-path
```

#### Ingress

```
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.domain.com
      paths:
        - path: /
          pathType: Prefix
```

#### Resource Limits

```
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 128Mi
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. **Fork** the repository.
2. **Create** a feature branch:

   ```
   git checkout -b feature/amazing-feature
   ```

3. **Commit** your changes:

   ```
   git commit -m 'Add some amazing feature'
   ```

4. **Push** to the branch:

   ```
   git push origin feature/amazing-feature
   ```

5. **Open** a Pull Request.

## Chart Development

To develop charts:

- Make changes to chart files.
- Update version in `Chart.yaml`.
- Generate documentation with helm-docs:

  ```
  helm-docs -t ./charts/chart-name/README.md.gotmpl
  ```

## Testing Charts

Test your charts using the following commands:

```
helm lint charts/chart-name
helm template charts/chart-name
helm test release-name --namespace namespace
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- The Kubernetes community
- The Helm project
- All the great open-source applications included in these charts

⭐ Star this repository if you find it helpful!
