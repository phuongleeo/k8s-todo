#!/usr/local/env bash
set -x
INSTALL_DIR=/usr/local/bin
ISTIO_SRC_DIR=$BINARY_DIR
echo "KUBECONFIG=$KUBECONFIG"
echo "BINARY_DIR=$BINARY_DIR"
echo "ISTIO_VERSION=$ISTIO_VERSION"
echo "ISTIO_OVERWRITE=$ISTIO_OVERWRITE"
echo "CERT_ARN=$CERT_ARN"
echo "Replace CERT_ARN"
sed -ie "s|__cert_arn|\"$CERT_ARN\"|" $ISTIO_OVERWRITE
cd /tmp
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cp /tmp/istio-$ISTIO_VERSION/bin/istioctl $INSTALL_DIR/istioctl
chmod +x $INSTALL_DIR/istioctl
echo "Init Operator"
$INSTALL_DIR/istioctl operator init
echo "istioctl install demo"
$INSTALL_DIR/istioctl install --set profile=demo --set addonComponents.grafana.enabled=true --skip-confirmation \
-f $ISTIO_OVERWRITE
echo "istioctl verify-install"
$INSTALL_DIR/istioctl verify-install
