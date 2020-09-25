#https://docs.aws.amazon.com/eks/latest/userguide/restrict-ec2-credential-access.html
yum install -y iptables-services
iptables --insert FORWARD 1 --in-interface eni+ --destination 169.254.169.254/32 --jump DROP
iptables-save | tee /etc/sysconfig/iptables
systemctl enable --now iptables
