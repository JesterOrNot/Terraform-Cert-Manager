# data "kubernetes_secret" "proxy-config-certificates" {
#   metadata {
#     name      = "proxy-config-certificates"
#     namespace = "default"
#   }

#   depends_on = [
#     helm_release.cert_manager,
#     kubernetes_manifest.clusterissuer,
#     kubernetes_manifest.certificate
#   ]
# }

# resource "local_file" "fullchain-pem" {
#   filename = "fullchain.pem"
#   content  = lookup(data.kubernetes_secret.proxy-config-certificates.data, "tls.crt", "")

#   depends_on = [
#     data.kubernetes_secret.proxy-config-certificates
#   ]
# }

# resource "local_file" "chain-pem" {
#   filename = "chain.pem"
#   content  = trimprefix("${element(split("-----END CERTIFICATE-----", local_file.fullchain-pem.content), 1)}-----END CERTIFICATE-----", "\n")

#   depends_on = [
#     data.kubernetes_secret.proxy-config-certificates
#   ]
# }

# resource "local_file" "privkey-pem" {
#   filename = "privkey.pem"
#   content  = lookup(data.kubernetes_secret.proxy-config-certificates.data, "tls.key", "")

#   depends_on = [
#     data.kubernetes_secret.proxy-config-certificates
#   ]
# }