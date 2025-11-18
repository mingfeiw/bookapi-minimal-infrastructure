resource "kubernetes_secret" "bookapi_secret" {
  metadata {
    name      = "bookapi-secret"
    namespace = kubernetes_namespace.bookapi_ns.metadata[0].name
  }

  data = {
    DbPassword = "bXlfcGFzc3dvcmQ="
    APIKEY     = "YXBpX2tleV92YWx1ZQ=="
  }

  type = "Opaque"
}