{{/*
Expand the name of the chart.
*/}}
{{- define "qbittorrent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "qbittorrent.fullname" -}}
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
Create a chart name with version.
*/}}
{{- define "qbittorrent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/*
Create environment variables used to configure the qbittorrent container as well as the VPN service.
*/}}
{{- define "qbittorrent.env" -}}
- name: WEBUI_PORTS
  value: {{ .Values.env.WEBUI_PORTS | quote }}
- name: PUID
  value: {{ .Values.env.PUID | quote }}
- name: PGID
  value: {{ .Values.env.PGID | quote }}
- name: UMASK
  value: {{ .Values.env.UMASK | quote }}
- name: TZ
  value: {{ .Values.env.TZ | quote }}
{{- if .Values.vpn.enabled }}
- name: VPN_ENABLED
  value: {{ .Values.vpn.enabled | quote }}
- name: VPN_CONF
  value: {{ .Values.env.VPN_CONF | quote }}
- name: VPN_PROVIDER
  value: {{ .Values.vpn.provider | quote }}
- name: VPN_LAN_NETWORK
  value: {{ .Values.env.VPN_LAN_NETWORK | quote }}
- name: VPN_LAN_LEAK_ENABLED
  value: {{ .Values.env.VPN_LAN_LEAK_ENABLED | quote }}
- name: VPN_EXPOSE_PORTS_ON_LAN
  value: {{ .Values.env.VPN_EXPOSE_PORTS_ON_LAN | quote }}
- name: VPN_AUTO_PORT_FORWARD
  value: {{ .Values.env.VPN_AUTO_PORT_FORWARD | quote }}
- name: VPN_AUTO_PORT_FORWARD_TO_PORTS
  value: {{ .Values.env.VPN_AUTO_PORT_FORWARD_TO_PORTS | quote}}
- name: VPN_KEEP_LOCAL_DNS
  value: {{ .Values.env.VPN_KEEP_LOCAL_DNS | quote }}
- name: VPN_FIREWALL_TYPE
  value: {{ .Values.env.VPN_FIREWALL_TYPE | quote }}
- name: VPN_HEALTHCHECK_ENABLED
  value: {{ .Values.env.VPN_HEALTHCHECK_ENABLED | quote }}
- name: PRIVOXY_ENABLED
  value: {{ .Values.env.PRIVOXY_ENABLED | quote }}
- name: UNBOUND_ENABLED
  value: {{ .Values.env.UNBOUND_ENABLED | quote }}
{{- if eq .Values.vpn.provider "pia" }}
- name: VPN_PIA_PREFERRED_REGION
  value: {{ .Values.env.VPN_PIA_PREFERRED_REGION | quote }}
{{- if .Values.env.VPN_PIA_DIP_TOKEN}}
- name: VPN_PIA_DIP_TOKEN
  value: {{ .Values.env.VPN_PIA_DIP_TOKEN | quote }}
{{- end }}
- name: VPN_PIA_PORT_FORWARD_PERSIST
  value: {{ .Values.env.VPN_PIA_PORT_FORWARD_PERSIST | quote }}
{{- if and .Values.vpn.existingSecret .Values.vpn.existingKeys.usernameKey (not .Values.env.VPN_PIA_USER) }}
- name: VPN_PIA_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.vpn.existingSecret | quote }}
      key: {{ .Values.vpn.existingKeys.usernameKey | quote }}
{{- else }}
- name: VPN_PIA_USER
  value: {{ required "PIA username required" .Values.env.VPN_PIA_USER | quote }}
{{- end }}
{{- if and .Values.vpn.existingSecret .Values.vpn.existingKeys.passwordKey (not .Values.env.VPN_PIA_PASS) }}
- name: VPN_PIA_PASS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.vpn.existingSecret | quote }}
      key: {{ .Values.vpn.existingKeys.passwordKey | quote }}
{{- else }}
- name: VPN_PIA_PASS
  value: {{ required "PIA password required" .Values.env.VPN_PIA_PASS | quote }}
{{- end }}
{{- end }} # eq .Values.vpn.provider "pia"
{{- end }} # .Values.vpn.enabled
{{- if .Values.extraEnv }}
{{ toYaml .Values.extraEnv }}
{{- end }}
{{- end -}}
