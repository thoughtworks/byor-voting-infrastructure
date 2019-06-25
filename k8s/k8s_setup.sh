#!/bin/sh

set -e;

helm_path=/usr/local/bin/helm

KIALI_USERNAME=$(read '?Kiali Username: ' kialiusernameval && echo -n $kialiusernameval | base64)
KIALI_PASSPHRASE=$(read -s "?Kiali Passphrase: " kialipasswordval && echo -n $kialipasswordval | base64)
AWS_SECRET_KEY_ID=$(read -s "?Aws awssecretkeyid: " awssecretkeyid && echo -n $awssecretkeyid | base64)

################### Exporting Kubernetes configuration ###################
read -e -p "Please enter the AWS region [eu-west-1]: " inkubeConfig;
KUBECONFIG="${inkubeConfig:-output/byor/kubeconfig-byor}"

export KUBECONFIG=${KUBECONFIG} >> ${HOME}/.bashrc

if [ -f $helm_path ] 
then
echo " Kubernetes-helm already installed .........."
else   
  echo " Installing Helm .........."
  curl -LO https://git.io/get_helm.sh
  chmod 700 get_helm.sh
  ./get_helm.sh  
fi

helm init --service-account tiller

kubectl label namespace default istio-injection=enabled

################ Istio Installation ################

sleep 60

helm repo add istio https://storage.googleapis.com/istio-release/releases/1.1.7/charts/

helm repo update

helm install istio/istio-init --name istio-init --set certmanager.enabled=true --namespace istio-system

sleep 30

helm install istio/istio --name istio --namespace istio-system --set tracing.enabled=true --set kiali.enabled=true --set grafana.enabled=true

kubectl label namespace istio-system istio-injection=enabled

################ Cert-Manager Installation ################

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

kubectl label namespace istio-system certmanager.k8s.io/disable-validation=true

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install --name cert-manager --namespace istio-system --version v0.8.0 jetstack/cert-manager

################ Configuring Kiali Secrets ################

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF

################ Configuring Secrets for Lets encrypt issuer ################

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: prod-route53-credentials-secret
  namespace: istio-system
  labels:
    app: prod-route53-credentials-secret
type: Opaque
data:
  secret-access-key: $AWS_SECRET_KEY_ID
EOF
