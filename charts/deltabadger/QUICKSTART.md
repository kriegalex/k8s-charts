# Deltabadger Helm Chart - Quick Start Guide

**Modern Helm chart using [bjw-s common library](https://github.com/bjw-s-labs/helm-charts)**

## Prerequisites

- Kubernetes cluster (1.28+)
- Helm 3.17+ installed
- kubectl configured to access your cluster

---

## Quick Install (5 minutes)

```bash
# 1. Setup dependencies (one-time)
helm repo add bjw-s https://bjw-s-labs.github.io/helm-charts
helm repo update
cd deltabadger-helm
helm dependency update

# 2. Install
helm install deltabadger .

# 3. Wait for ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=deltabadger --timeout=120s

# 4. Access the app
kubectl port-forward svc/deltabadger-app 3737:3000
# Open http://localhost:3737
```

Secrets are auto-generated on first start (`SECRET_KEY_BASE` is persisted to
`/app/storage/.secrets` on the PVC), so no secret setup is needed. To manage
`SECRET_KEY_BASE` yourself, see the options below.

---

## Installation Options

### Option 1: Local Development / Testing

Uses default configuration with auto-generated secrets.

```bash
# Install
helm install deltabadger . --create-namespace --namespace deltabadger

# Access via port-forward
kubectl port-forward -n deltabadger svc/deltabadger-app 3737:3000
```

**What you get:**
- ✓ 10Gi persistent storage
- ✓ ClusterIP service (no ingress)
- ✓ Default resources (250m CPU, 512Mi RAM)
- ✓ Auto-generated secrets (persisted on the PVC)

---

### Option 2: Production with Ingress & SSL

For production deployments with SSL. Secrets are auto-generated; add
`--set secrets.secrets.enabled=true --set secrets.secrets.stringData.SECRET_KEY_BASE=...`
only if you want to manage `SECRET_KEY_BASE` yourself.

```bash
# Install with production values
helm install deltabadger . \
  --create-namespace \
  --namespace deltabadger \
  --set ingress.app.enabled=true \
  --set ingress.app.className=nginx \
  --set "ingress.app.hosts[0].host=deltabadger.yourdomain.com" \
  --set "ingress.app.hosts[0].paths[0].path=/" \
  --set "ingress.app.hosts[0].paths[0].pathType=Prefix" \
  --set "ingress.app.hosts[0].paths[0].service.identifier=app" \
  --set "ingress.app.hosts[0].paths[0].service.port=http" \
  --set "ingress.app.tls[0].secretName=deltabadger-tls" \
  --set "ingress.app.tls[0].hosts[0]=deltabadger.yourdomain.com" \
  --set ingress.app.annotations."cert-manager\.io/cluster-issuer"=letsencrypt-prod \
  --set controllers.deltabadger.containers.app.env.APP_ROOT_URL="https://deltabadger.yourdomain.com" \
  --set controllers.deltabadger.containers.app.env.HOME_PAGE_URL="https://deltabadger.yourdomain.com" \
  --set controllers.deltabadger.containers.app.env.FORCE_SSL="true" \
  --set persistence.storage.size=20Gi

# Check status
helm status deltabadger -n deltabadger
kubectl get ingress -n deltabadger
```

**Or use a values file** (see `examples/production-values.yaml`):

```bash
# Copy and customize example
cp examples/production-values.yaml my-values.yaml
# Edit my-values.yaml with your domain and secrets

# Install
helm install deltabadger . -f my-values.yaml -n deltabadger --create-namespace
```

**What you get:**
- ✓ HTTPS ingress with cert-manager
- ✓ 20Gi storage
- ✓ Ready for public access

---

### Option 3: Production with External Secrets

Keeps secrets out of Helm values, for when you want to manage `SECRET_KEY_BASE`
yourself instead of relying on the auto-generated one.

```bash
# 1. Create Kubernetes secret first
kubectl create namespace deltabadger
kubectl create secret generic deltabadger-secrets \
  --namespace deltabadger \
  --from-literal=SECRET_KEY_BASE=$(openssl rand -hex 64)

# 2. Install referencing external secret
helm install deltabadger . \
  --namespace deltabadger \
  -f examples/external-secrets-values.yaml

# 3. Verify
kubectl get all -n deltabadger
```

**What you get:**
- ✓ Secrets managed outside Helm
- ✓ Better security posture
- ✓ Compatible with external-secrets operator, sealed-secrets, etc.

---

## Verification Steps

After installation, verify everything is working:

```bash
# Check all resources
kubectl get all -n deltabadger

# Check pod is running
kubectl get pods -n deltabadger
# Should show: STATUS=Running, READY=1/1

# Check logs (should see Rails server starting)
kubectl logs -n deltabadger -l app.kubernetes.io/instance=deltabadger --tail=50

# Test health endpoint
kubectl port-forward -n deltabadger svc/deltabadger-app 3737:3000 &
curl http://localhost:3737/up
# Should return: HTTP 200 OK

# Check storage is bound
kubectl get pvc -n deltabadger
# STATUS should be: Bound
```

---

## Common Operations

### View Logs

```bash
# Follow logs
kubectl logs -n deltabadger -l app.kubernetes.io/instance=deltabadger -f

# Last 100 lines
kubectl logs -n deltabadger -l app.kubernetes.io/instance=deltabadger --tail=100
```

### Upgrade

```bash
# Pull latest chart changes
git pull

# Update dependencies if Chart.yaml changed
helm dependency update

# Upgrade release
helm upgrade deltabadger . -n deltabadger -f my-values.yaml

# Or upgrade just the image version
helm upgrade deltabadger . -n deltabadger \
  --set controllers.deltabadger.containers.app.image.tag=2.23.3 \
  --reuse-values
```

### Upgrading from chart 1.x (app 1.6.x) to chart 2.x (app 2.x)

Chart 2.0.0 moves to the Deltabadger 2.x image. Two things changed:

- **Health endpoint**: probes now use `/up` (the old `/health-check` route was
  removed upstream). Handled automatically by the chart defaults — only relevant
  if you overrode the probes.
- **Secrets**: `SECRET_KEY_BASE` is auto-generated and persisted to
  `/app/storage/.secrets`; `DEVISE_SECRET_KEY` and `APP_ENCRYPTION_KEY` are now
  legacy keys, read only by the one-time `MigrateToRailsEncryption` migration.

⚠️ **Before upgrading an existing 1.x install**, make sure the exact
`SECRET_KEY_BASE`, `DEVISE_SECRET_KEY` and `APP_ENCRYPTION_KEY` values your 1.x
release ran with are still provided (chart 2.x disables the chart-managed Secret
by default — re-enable it with your old values):

```yaml
secrets:
  secrets:
    enabled: true
    stringData:
      SECRET_KEY_BASE: "<your existing value>"
      DEVISE_SECRET_KEY: "<your existing value>"
      APP_ENCRYPTION_KEY: "<your existing value>"
```

Note: chart 1.x shipped insecure development defaults for these — if you never
overrode them, your existing data was encrypted with those defaults, so you must
pass those same default strings during the upgrade (see the chart 1.x
`values.yaml`). Without the original keys the migration cannot decrypt existing
exchange API credentials.

After the migration has run once, `DEVISE_SECRET_KEY` and `APP_ENCRYPTION_KEY`
can be removed. **`SECRET_KEY_BASE` must be kept unchanged forever**: the app
derives its database encryption keys from it, so changing it makes re-encrypted
data (exchange API credentials) unreadable.

### Backup Data

```bash
# Get pod name
POD=$(kubectl get pod -n deltabadger -l app.kubernetes.io/instance=deltabadger -o jsonpath='{.items[0].metadata.name}')

# Create backup archive
kubectl exec -n deltabadger $POD -- tar czf /tmp/backup.tar.gz -C /app/storage .

# Copy to local machine
kubectl cp -n deltabadger $POD:/tmp/backup.tar.gz ./deltabadger-backup-$(date +%Y%m%d).tar.gz

# Verify backup
tar -tzf ./deltabadger-backup-$(date +%Y%m%d).tar.gz | head
```

### Uninstall

```bash
# Remove Helm release (keeps PVC by default)
helm uninstall deltabadger -n deltabadger

# Delete PVC (⚠️ destroys all data)
kubectl delete pvc -n deltabadger -l app.kubernetes.io/instance=deltabadger

# Delete namespace
kubectl delete namespace deltabadger
```

---

## Troubleshooting

### Pod won't start

```bash
# Check pod status and events
kubectl describe pod -n deltabadger -l app.kubernetes.io/instance=deltabadger

# Common issues:
# - ImagePullBackOff: Check image name/tag
# - CrashLoopBackOff: Check logs for application errors
# - Pending: Check PVC is bound, sufficient resources
```

### PVC stuck in Pending

```bash
# Check PVC status
kubectl get pvc -n deltabadger
kubectl describe pvc -n deltabadger -l app.kubernetes.io/instance=deltabadger

# Check available storage classes
kubectl get storageclass

# Solutions:
# - If no default storage class, set one: kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
# - Or specify in values: persistence.storage.storageClass: "your-class"
```

### Ingress not working

```bash
# Check ingress status
kubectl get ingress -n deltabadger
kubectl describe ingress -n deltabadger -l app.kubernetes.io/instance=deltabadger

# Check ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=50

# Verify DNS resolves to ingress IP
kubectl get ingress -n deltabadger -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
nslookup deltabadger.yourdomain.com
```

### Dependencies not found

If you see "dependency not found" errors:

```bash
# Re-add repository
helm repo add bjw-s https://bjw-s-labs.github.io/helm-charts
helm repo update

# Re-download dependencies
cd deltabadger-helm
helm dependency update

# Verify charts/ directory has common-4.6.2.tgz
ls -lh charts/
```

### Health check failing

```bash
# Check if app is listening on correct port
kubectl exec -n deltabadger -it deployment/deltabadger -- netstat -tlnp | grep 3000

# Check health endpoint manually
kubectl exec -n deltabadger -it deployment/deltabadger -- curl -v http://localhost:3000/up

# Check startup time (may need longer initialDelaySeconds)
kubectl logs -n deltabadger -l app.kubernetes.io/instance=deltabadger | grep -i "listening\|started\|ready"
```

### Background jobs not processing

If orders or notifications aren't being processed:

```bash
# Check logs for Solid Queue messages
kubectl logs -n deltabadger -l app.kubernetes.io/instance=deltabadger | grep -i "solid\|queue\|job"

# Verify running in standalone mode (should see SOLID_QUEUE_IN_PUMA)
kubectl logs -n deltabadger -l app.kubernetes.io/instance=deltabadger | head -50
```

The chart defaults to `standalone` mode which runs jobs in-process. If you've overridden the command to `web`, you need a separate jobs container (see Deployment Modes section).

---

## Deployment Modes

This chart runs in **standalone mode** by default, matching the docker-compose behavior:

- **Standalone mode** (default): Single container with in-process job handling via Solid Queue in Puma. Ideal for small to medium deployments.
- **Web + Jobs mode**: Separate containers for web and background jobs. Better for scaling. To use this mode, override the command and deploy a separate jobs pod.

### Switching to Web + Jobs Mode

```yaml
# values.yaml override for web-only container
controllers:
  deltabadger:
    containers:
      app:
        args: ["web"]
        env:
          AUTO_MIGRATE: "true"  # Run migrations on web startup

# Add a separate jobs deployment
  jobs:
    enabled: true
    type: deployment
    replicas: 1
    containers:
      jobs:
        image:
          repository: ghcr.io/deltabadger/deltabadger
          tag: latest
        args: ["jobs"]
        envFrom:
          - secretRef:
              name: deltabadger
```

---

## Understanding bjw-s Common Library

This chart uses the **bjw-s common library** instead of custom templates.

**Key differences from traditional charts:**

| Traditional Chart | bjw-s Common Library |
|-------------------|----------------------|
| Custom templates in `templates/` | One template that calls library |
| ~500-1000 lines of YAML | ~200 lines of config |
| Manual maintenance | Library auto-updates |
| Service name: `deltabadger` | Service name: `deltabadger-app` |

**Service naming:**
- Main service: `deltabadger-app` (note the `-app` suffix)
- Why? The library uses identifiers, and our service identifier is `app`
- Port forward: `kubectl port-forward svc/deltabadger-app 3737:3000`

**Configuration structure:**
```yaml
controllers:      # Deployments, DaemonSets, StatefulSets
  deltabadger:   # Controller identifier
    containers:  # Container definitions
      app:       # Container identifier

service:         # Services
  app:           # Service identifier → becomes deltabadger-app

ingress:         # Ingress rules
  app:           # Ingress identifier
```

**Learn more:**
- [bjw-s Common Library Docs](https://bjw-s-labs.github.io/helm-charts/docs/common-library/)
- [App Template Examples](https://github.com/bjw-s-labs/helm-charts/tree/main/charts/other/app-template)

---

## Next Steps

- **Production deployment**: Review [README.md](README.md) for all configuration options
- **Example configurations**: Check [examples/](examples/) directory
- **Email notifications**: See [examples/with-email-values.yaml](examples/with-email-values.yaml)
- **Get help**: Join [Deltabadger Telegram](https://t.me/deltabadgerchat)
- **Report issues**: [GitHub Issues](https://github.com/deltabadger/deltabadger/issues)

---

## Security Checklist for Production

Before going to production:

- [ ] Generate new secrets (not default dev secrets)
- [ ] Enable SSL/TLS with valid certificates
- [ ] Set appropriate resource limits
- [ ] Configure persistent storage with backups
- [ ] Review and set `ALLOWED_HOSTS` if needed
- [ ] Set up monitoring/alerts
- [ ] Test backup and restore procedures
- [ ] Use external secrets management (recommended)
- [ ] Enable network policies (optional but recommended)
