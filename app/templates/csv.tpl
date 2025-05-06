{{ range . }}
{{- $target := .Target -}}
{{- range .Vulnerabilities }}
    {{- $description := .Title }}
    {{- if not $description }}
        {{- $description = .Description -}}
        {{- if gt (len $description ) 3000 -}}
            {{- $description = (slice $description 0 3000) | printf "%v..." -}}
        {{- end}}
    {{- end }}
    {{- $target }},
    {{- .PkgName }},
    {{- .VulnerabilityID }},
    {{- .Vulnerability.Severity }},
    {{- $nvdScore := "" -}}
    {{- $redhatScore := "" -}}
    {{- range $key, $value := .Vulnerability.CVSS -}}
        {{- if eq $key "nvd" -}}
            {{- $nvdScore = printf "%.1f" $value.V3Score -}}
        {{- else if eq $key "redhat" -}}
            {{- $redhatScore = printf "%.1f" $value.V3Score -}}
        {{- end -}}
    {{- end -}}
    {{- if $nvdScore -}}
        {{- $nvdScore }},
    {{- else if $redhatScore -}}
        {{- $redhatScore }},
    {{- else -}}
        ,
    {{- end -}}
    {{- .InstalledVersion }},
    {{- $fixedVersions := .FixedVersion | replace ", " "-" }}
    {{- printf "%q" $fixedVersions }},
    {{- replace "," ";" $description }},
    {{- .PrimaryURL }}
{{ end -}}
{{- end }}