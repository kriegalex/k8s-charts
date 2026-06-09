{{/*
Expand the name of the chart.
*/}}
{{- define "valheim-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "valheim-server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "valheim-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "valheim-server.labels" -}}
helm.sh/chart: {{ include "valheim-server.chart" . }}
{{ include "valheim-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "valheim-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "valheim-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Returns a non-empty string when any backup feature is enabled (scheduled, on-update, or
on-shutdown). Used to decide whether the backups PVC should be provisioned.
*/}}
{{- define "valheim-server.backupsEnabled" -}}
{{- if or (eq (.Values.automation.autoBackup | toString) "1") (eq (.Values.automation.autoBackupOnUpdate | toString) "1") (eq (.Values.automation.autoBackupOnShutdown | toString) "1") -}}
true
{{- end -}}
{{- end }}