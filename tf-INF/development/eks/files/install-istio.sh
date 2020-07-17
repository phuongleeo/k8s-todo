#!/usr/local/env bash
INSTALL_DIR=/usr/local/bin
echo "KUBECONFIG=$KUBECONFIG"
cd /tmp/

# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.6.5 sh -
cp /tmp/istio-1.6.5/bin/istioctl $INSTALL_DIR/istioctl
chmod +x $INSTALL_DIR/istioctl
echo "istioctl install demo"
$INSTALL_DIR/istioctl install --set profile=demo --skip-confirmation
echo "istioctl verify-install"
$INSTALL_DIR/istioctl verify-install
