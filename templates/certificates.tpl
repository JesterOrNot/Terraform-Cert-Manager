apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: letsencrypt-certificate
spec:
  renewBefore: 24h
  secretName: proxy-config-certificates
  dnsNames:
    ${indent(4, yamlencode(dnsNames))}
  issuerRef:
    name: letsencrypt-issuer
    kind: ClusterIssuer
