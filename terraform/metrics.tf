resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = "kube-system"
  chart            = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  version          = "3.12.2"
  create_namespace = false

  values = [
    <<EOF
        args:
            - --kubelet-insecure-tls
    EOF
  ]
}
