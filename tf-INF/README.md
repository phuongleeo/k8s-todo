# Deploy a Production Ready for MVP project
 Kubernetes Production Runtime (BKPR)
# Components
- [EKS with spot worker groups + launch template](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/12.2.0)

- [included node termination handler](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md)
- [Prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator)
![](https://landscape.cncf.io/logos/prometheus.svg)
- Habor
![Habor](https://raw.githubusercontent.com/goharbor/harbor/5d31dd5b57d83f300907744aabf13ca60aac19b3/docs/img/harbor-arch.png)
- [External-dns](https://hub.helm.sh/charts/bitnami/external-dns)
![](https://github.com/kubernetes-sigs/external-dns/blob/master/img/external-dns.png?raw=true)
- metrics-server
- [EFK](https://banzaicloud.com/docs/one-eye/logging-operator/quickstarts/es-nginx/)
![](https://landscape.cncf.io/logos/fluentd.svg)


## Quick Start

To deploy the cluster you can use :

### Terraform

#### Usage

```ShellSession
# Run make
make all-init
make all-plan
```

###Reference
Harbor: https://ruzickap.github.io/k8s-harbor/part-07/#upload-docker-image
