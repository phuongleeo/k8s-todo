# Deploy a Production Ready
Kubernetes Production Runtime (BKPR) ( This project is being worked in progress )

 <img src="https://res.cloudinary.com/practicaldev/image/fetch/s--b2dyI-nF--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://github.com/mhmdio/mhmdio.github.io/raw/master/images/amazoneks.jpg" width="70%" >

# Components
- [EKS with spot worker groups + launch template](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/12.2.0)

- [included node termination handler](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md)

- Ingress
 - [Istio](https://github.com/istio/istio)

   <img src="https://avatars3.githubusercontent.com/u/23534644?s=200&v=4" width="70%">

  - [Nginx](https://kubernetes.github.io/ingress-nginx/)

   <img src="https://developers.redhat.com/blog/wp-content/uploads/2019/06/5-Using-NGINX-Ingress-Controller.png" width="70%">


- Monitoring
 - [Prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator)

  <img src="https://landscape.cncf.io/logos/prometheus.svg" width="70%" />

 - [EFK](https://banzaicloud.com/docs/one-eye/logging-operator/quickstarts/es-nginx/)

    <img src="https://img.icons8.com/color/452/elasticsearch.png" width="40%">
    <img src="https://fluentbit.io/assets/img/logo1-default.png" width="70%">


- CI/CD + Progressive delivery
 - [ArgoCD](https://argoproj.github.io)

   <img src="https://github.com/argoproj/argoproj/blob/master/docs/assets/argo.png?raw=true" width="70%" />

 - [Flagger](https://github.com/weaveworks/flagger)

   <img src="https://miro.medium.com/max/1208/1*roBSiQ6K97oHEaFOvgftPQ.jpeg" width="70%">


- Registry
 - [Habor](https://github.com/goharbor/harbor)

   <img src="https://raw.githubusercontent.com/goharbor/harbor/5d31dd5b57d83f300907744aabf13ca60aac19b3/docs/img/harbor-arch.png" width="70%" />

- Apps
 - [External-dns](https://hub.helm.sh/charts/bitnami/external-dns)

  <img src="https://github.com/kubernetes-sigs/external-dns/blob/master/img/external-dns.png?raw=true" width="70%" />

 - [metrics-server](https://github.com/kubernetes-sigs/metrics-server)





## Quick Start

To deploy the cluster you can use :

### Terraform

#### Usage
Please replace your own variables in `terraform.tfvars` and `variables.tf` files

```ShellSession
# Run make
make all-init
make all-plan
```

###Reference
Harbor: https://ruzickap.github.io/k8s-harbor/part-07/#upload-docker-image
