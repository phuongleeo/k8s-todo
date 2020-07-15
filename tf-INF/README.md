# Deploy a Production Ready for MVP project

# Components
- EKS with spot worker groups + launch template
- included node termination handler
- [Prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator)
- Habor
![Habor](https://raw.githubusercontent.com/goharbor/harbor/5d31dd5b57d83f300907744aabf13ca60aac19b3/docs/img/harbor-arch.png)
- external-dns
- metrics-server
- EFK


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