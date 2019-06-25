locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: ${aws_eks_cluster.cluster.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.cluster.name}
    user: ${aws_eks_cluster.cluster.name}
  name: ${aws_eks_cluster.cluster.name}
current-context: ${aws_eks_cluster.cluster.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.cluster.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.cluster.name}"
KUBECONFIG

  aws_auth = <<AWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
${var.aws_auth}
AWSAUTH

  eks_admin = <<EKSADMIN
apiVersion: v1
kind: ServiceAccount
metadata:
  name: k8s-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: k8s-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: k8s-admin
  namespace: kube-system
EKSADMIN

tiller_svc = <<TILLERSVC
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
TILLERSVC
}