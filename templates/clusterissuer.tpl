apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-issuer
  namespace: default
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "${email}"
    privateKeySecretRef:
      name: letsencrypt-key
    solvers:
      - dns01:
          route53:
            region: ${region}
            hostedZoneID: ${zone_id}
            role: ${role_arn}
