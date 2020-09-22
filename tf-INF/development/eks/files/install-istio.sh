#!/usr/local/env bash
set -x
INSTALL_DIR=/usr/local/bin
ISTIO_SRC_DIR=$BINARY_DIR
KUBECONFIG=${KUBECONFIG}
ISTIO_VERSION=${ISTIO_VERSION}
ISTIO_OVERWRITE=${ISTIO_OVERWRITE}
echo "KUBECONFIG=$KUBECONFIG"
echo "BINARY_DIR=$BINARY_DIR"
echo "ISTIO_VERSION=$ISTIO_VERSION"
echo "ISTIO_OVERWRITE=$ISTIO_OVERWRITE"
cd /tmp
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cp /tmp/istio-$ISTIO_VERSION/bin/istioctl $INSTALL_DIR/istioctl
chmod +x $INSTALL_DIR/istioctl
echo "Init Operator"
$INSTALL_DIR/istioctl operator init
echo "Generate istio manifest prior to install"
$INSTALL_DIR/istioctl manifest generate --set profile=demo \
--set addonComponents.grafana.enabled=true \
-f $ISTIO_OVERWRITE > /tmp/generated-manifest.yaml
echo "istioctl install demo"
$INSTALL_DIR/istioctl install --set profile=demo --set addonComponents.grafana.enabled=true --skip-confirmation \
-f $ISTIO_OVERWRITE
echo "istioctl verify-install"
$INSTALL_DIR/istioctl verify-install -f /tmp/generated-manifest.yaml
