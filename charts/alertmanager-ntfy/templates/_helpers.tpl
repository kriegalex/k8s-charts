{{/*
Expand the name of the chart.
*/}}
{{- define "alertmanager-ntfy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "alertmanager-ntfy.fullname" -}}
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
{{- define "alertmanager-ntfy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "alertmanager-ntfy.labels" -}}
helm.sh/chart: {{ include "alertmanager-ntfy.chart" . }}
{{ include "alertmanager-ntfy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "alertmanager-ntfy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alertmanager-ntfy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "alertmanager-ntfy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "alertmanager-ntfy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve the ntfy template-path. If the user opted into the rendered
template ConfigMap and didn't set their own path, default to the mount
point. Returns empty when the binary should use its built-in formatter.
*/}}
{{- define "alertmanager-ntfy.templatePath" -}}
{{- if .Values.ntfyAlertmanager.ntfy.templatePath -}}
{{- .Values.ntfyAlertmanager.ntfy.templatePath -}}
{{- else if and .Values.ntfyAlertmanager.template.enabled .Values.ntfyAlertmanager.template.body -}}
/etc/ntfy-alertmanager/template.tmpl
{{- end -}}
{{- end -}}
