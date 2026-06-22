environment         = "prod"
vpc_cidr            = "172.16.0.0/16" # Rede 100% isolada do ambiente de desenvolvimento
public_subnet_cidr  = "172.16.1.0/24"
private_subnet_cidr = "172.16.2.0/24"
instance_type       = "t3.small" # Instância com mais recursos para Produção
ami_id              = "ami-0c7217cdde317cfec"