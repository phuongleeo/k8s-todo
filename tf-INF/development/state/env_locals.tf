locals {
  whitelist_ips = [
  ]
}

locals {
  public_domain     = "pub.${var.project}.com"
  private_domain    = "priv.${var.project}.com"
  production_domain = "${var.project}.com"
  regions = {
    asia   = "${var.project}.asia"
    co_kr  = "${var.project}.co.kr"
    kr     = "${var.project}.kr"
    hk     = "${var.project}.hk"
    com_hk = "${var.project}.com.hk"
    com_tw = "${var.project}.com.tw"
    tw     = "${var.project}.tw"
    cn     = "${var.project}.cn"
    com_my = "${var.project}.com.my"
    my     = "${var.project}.my"
    com_ph = "${var.project}.com.ph"
    ph     = "${var.project}.ph"
    com_sg = "${var.project}.com.sg"
    sg     = "${var.project}.sg"
    co_nz  = "${var.project}.co.nz"
    nz     = "${var.project}.nz"
    co_th  = "${var.project}.co.th"

    jp = "${var.project}.jp"
    in = "${var.project}.in"
    la = "${var.project}.la"
    ml = "${var.project}.ml"
    vn = "${var.project}.vn"

    honestbeepay = "honestbeepay.com."
    sumo         = "sumopay.sg."
  }
}

locals {
  prod_cidr = "10.100.0.0/16" // production CIDR
  svc_cidr  = "10.200.0.0/16" // services CIDR
  stg_cidr  = "10.10.0.0/16"  // staging CIDR
}

locals {
  aiven_vpc_id     = "vpc-67be5800"
  aiven_cidr_block = "192.168.130.0/24"
}
