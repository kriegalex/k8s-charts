# Enshrouded Server Helm Chart

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: proton-v2.1.6](https://img.shields.io/badge/AppVersion-proton--v2.1.6-informational?style=flat-square)

A Helm chart for Enshrouded Dedicated Game Server

## Important Notes

This Helm chart is configured to run the Enshrouded server as user `steam` with UID/GID 10000:10000, as required by the container image. The persistent volume for save data is mounted at `/home/steam/enshrouded/savegame` and must be accessible by this user.

It is also recommended to set some minimal resources for your server:

```
resources:
  # -- We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube.
  limits:
    memory: 12Gi
  requests:
    cpu: 4000m
    memory: 4Gi
```

## Installing the Chart

```bash
# Add the repository
helm repo add k8s-charts https://kriegalex.github.io/k8s-charts/

# Install the chart
helm install my-enshrouded-server k8s-charts/enshrouded-server
```

## Persistence

This chart creates a PersistentVolumeClaim to store your Enshrouded server data. The volume will not be deleted when you uninstall the chart. If you want to delete the PVC, you need to do it manually.

```bash
kubectl delete pvc -l app.kubernetes.io/instance=my-enshrouded-server
```

## Updating the Server

The Enshrouded server will automatically update when new game versions are released if you use the default image tag.

To manually update the server:

```bash
helm upgrade my-enshrouded-server k8s-charts/enshrouded-server
```

## Accessing the Server

The chart creates a Service of type LoadBalancer by default. You can find the external IP with:

```bash
kubectl get svc my-enshrouded-server
```

## Managing Savegame Data

This section explains how to safely copy savegames between your local computer and the Kubernetes cluster.

### Copying Savegames to the Kubernetes PVC

To upload your existing Enshrouded savegames to the server, follow these steps:

#### 1. Scale Down the Enshrouded Server

First, scale down the Enshrouded server to prevent data corruption while copying files:

```bash
# Replace 'enshrouded-server' with your Helm release name
kubectl scale deployment enshrouded-server --replicas=0
```

#### 2. Scale Down the Enshrouded Server

Create a file named enshrouded-server-savegame.yaml with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: enshrouded-server-savegame
  labels:
    app: enshrouded-server-savegame
spec:
  securityContext:
    runAsUser: 10000
    fsGroup: 10000
  containers:
  - name: copy-container
    image: ubuntu:24.04
    command: ['sleep', 'infinity']
    volumeMounts:
    - name: savegame-data
      mountPath: /home/steam/enshrouded/savegame
  volumes:
  - name: savegame-data
    persistentVolumeClaim:
      # Replace with your PVC name
      claimName: enshrouded-server
```

Apply this manifest to create the pod:

```bash
kubectl apply -f enshrouded-server-savegame.yaml
```

#### 3. Copy Files from Local to PVC

Wait for the pod to be ready:
```bash
kubectl wait --for=condition=Ready pod/enshrouded-server-savegame
```
Copy your local savegame files to the PVC:
```bash
# For Windows (PowerShell)
# Replace C:\path\to\local\savegame with your local savegame directory
kubectl cp 'C:\path\to\local\savegame\' enshrouded-server-savegame:/home/steam/enshrouded/savegame/

# For macOS/Linux
# Replace /path/to/local/savegame with your local savegame directory
kubectl cp /path/to/local/savegame/ enshrouded-server-savegame:/home/steam/enshrouded/savegame/
```
#### 4. Verify File Permissions
Ensure files have correct permissions:
```bash
kubectl exec enshrouded-server-savegame -- ls -la /home/steam/enshrouded/savegame/
```
#### 5. Clean Up and Restart the Server
Delete the temporary pod:
```bash
kubectl delete pod enshrouded-server-savegame
```
Scale the Enshrouded server back up:
```bash
kubectl scale deployment enshrouded-server --replicas=1
```
### Retrieving Savegames from the Server
To download your savegames from the server to your local machine:

```bash
# Scale down the server first (optional but recommended)
kubectl scale deployment enshrouded-server --replicas=0

# Create the temporary pod as described above
kubectl apply -f copy-pod.yaml
kubectl wait --for=condition=Ready pod/enshrouded-server-savegame

# Copy from PVC to local (Windows PowerShell)
kubectl cp enshrouded-server-savegame:/home/steam/enshrouded/savegame/ 'C:\path\to\destination\'

# Copy from PVC to local (macOS/Linux)
kubectl cp enshrouded-server-savegame:/home/steam/enshrouded/savegame/ /path/to/destination/

# Clean up
kubectl delete pod enshrouded-server-savegame
kubectl scale deployment enshrouded-server --replicas=1
```

### Finding Your Local Savegame Files
Enshrouded savegame files are typically located at:

- Windows: C:\Program Files (x86)\Steam\userdata\STEAM_ID\1203620\remote\
- Linux (Steam/Proton): ~/.local/share/Steam/steamapps/compatdata/1203620/pfx/drive_c/users/steamuser/AppData/Local/Enshrouded/Saves

### Notes on Savegame Management
- Always scale down the server before copying files to prevent data corruption
- Savegame files use the .sav extension
- The container runs as UID/GID 10000:10000, which is why the copy pod uses the same values
- Making regular backups of your savegames is recommended

## Values

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment @type -- object |
| configMap.data | object | `{}` | Additional environment variables @type -- object |
| configMap.enabled | bool | `true` | Enable additional configuration via ConfigMap |
| enshrouded.existingSecret | string | `""` | Name of an existing Secret providing the server password instead of `serverPassword`. The Secret must contain a `SERVER_PASSWORD` key. When set, the chart does not render its own Secret and `serverPassword` is ignored — keeps the password out of Helm values entirely. |
| enshrouded.externalConfig | int | `0` | If you would rather manually supply a config file, set this to true (1) |
| enshrouded.gamePort | int | `15636` | Game server port (UDP) |
| enshrouded.maxPlayers | int | `16` | Maximum number of players |
| enshrouded.queryPort | int | `15637` | Query server port (UDP) |
| enshrouded.serverIP | string | 0.0.0.0 | Server IP address to bind to |
| enshrouded.serverName | string | `"My Enshrouded Server"` | Server name displayed in the server browser |
| enshrouded.serverPassword | string | `"changeme"` | Server password (leave blank for no password) |
| fullnameOverride | string | `""` | Override the full name of the chart |
| image.pullPolicy | string | `"Always"` | Image pull policy |
| image.repository | string | `"sknnr/enshrouded-dedicated-server"` | Repository for the Enshrouded Server image |
| image.tag | string | `""` | Specify a tag, defaults to Chart.appVersion |
| imagePullSecrets | list | `[]` | ImagePullSecrets for private docker registry |
| livenessProbe.enabled | bool | `false` | Enable livenessProbe |
| livenessProbe.failureThreshold | int | `6` | Number of failures before giving up @description -- Allow up to 2 minutes for initial startup |
| livenessProbe.initialDelaySeconds | int | `60` | Initial delay before probing |
| livenessProbe.periodSeconds | int | `20` | Period between probes |
| livenessProbe.timeoutSeconds | int | `5` | Timeout for each probe |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node selector for pod assignment @type -- object |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access mode for the volume |
| persistence.annotations | object | `{}` | Annotations for PVC |
| persistence.enabled | bool | `true` | Enable persistence using Persistent Volume Claims |
| persistence.existingClaim | string | `""` | Existing PVC to use (required if persistence.enabled is true) |
| persistence.size | string | `"10Gi"` | Size of persistent volume claim |
| persistence.storageClassName | string | `""` | StorageClass for PVC @description -- If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined or null, no storageClassName spec is set, choosing the default provisioner |
| podAnnotations | object | `{}` | Annotations to add to pods |
| podDisruptionBudget.enabled | bool | `false` | Enable PodDisruptionBudget |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| podSecurityContext.fsGroup | int | `10000` | Group ID to run the container |
| podSecurityContext.runAsUser | int | `10000` | User ID to run the container |
| readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| readinessProbe.failureThreshold | int | `20` | Number of failures before giving up @description -- Allow up to 5 minutes for readiness |
| readinessProbe.initialDelaySeconds | int | `60` | Initial delay before probing |
| readinessProbe.periodSeconds | int | `15` | Period between probes |
| readinessProbe.timeoutSeconds | int | `5` | Timeout for each probe |
| resources | object | `{}` | Resource requests and limits @description -- We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. |
| securityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation |
| securityContext.capabilities.drop | list | `["ALL"]` | Linux capabilities to remove |
| service.annotations | object | `{}` | Annotations for the service |
| service.gamePort | object | `{"port":15636,"protocol":"UDP","targetPort":15636}` | Game port configuration |
| service.gamePort.port | int | `15636` | Port exposed by the service |
| service.gamePort.protocol | string | `"UDP"` | Protocol used by the port |
| service.gamePort.targetPort | int | `15636` | Port targetted on the pods |
| service.loadBalancerIP | string | `""` | LoadBalancer IP (optional, cloud specific) |
| service.loadBalancerSourceRanges | list | `[]` | Specify the allowed IPs for LoadBalancer |
| service.queryPort | object | `{"port":15637,"protocol":"UDP","targetPort":15637}` | Query port configuration |
| service.queryPort.port | int | `15637` | Port exposed by the service |
| service.queryPort.protocol | string | `"UDP"` | Protocol used by the port |
| service.queryPort.targetPort | int | `15637` | Port targetted on the pods |
| service.type | string | `"LoadBalancer"` | Service type @valid -- "ClusterIP" "NodePort" "LoadBalancer" "ExternalName" |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| startupProbe.enabled | bool | `true` | Enable startupProbe |
| startupProbe.failureThreshold | int | `30` | Number of failures before giving up @description -- Allow up to 5 minutes for initial startup |
| startupProbe.initialDelaySeconds | int | `30` | Initial delay before probing |
| startupProbe.periodSeconds | int | `10` | Period between probes |
| startupProbe.timeoutSeconds | int | `5` | Timeout for each probe |
| tolerations | list | `[]` | Tolerations for pod assignment @type -- array |
| updateStrategy.rollingUpdate | object | `{"maxSurge":0,"maxUnavailable":1}` | Rolling update configuration parameters |
| updateStrategy.rollingUpdate.maxSurge | int | `0` | Maximum number of new pods that can be created during the update |
| updateStrategy.rollingUpdate.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during the update |
| updateStrategy.type | string | `"RollingUpdate"` | Update strategy @valid -- "RollingUpdate" "Recreate" |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
