resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.private_key.private_key_pem

  subject {
    common_name  = "*.example.com"
    organization = "My Company"
  }

  validity_period_hours = 8760
  is_ca_certificate     = true
  allowed_uses          = ["server_auth"]
}

resource "kubernetes_secret" "tls_secret" {
  metadata {
    name      = "my-go-app-tls"
    namespace = "default"
  }

  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.private_key.private_key_pem
  }

  type = "kubernetes.io/tls"
}