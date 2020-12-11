### VPC

# use terraform cloud remote backend OR you can use your prefered remote backend

#terraform {
#  backend "remote" {
#    organization = "my-tf-cloud-org"
#    workspaces {
#      name = "my-workspace"
#    }
#  }
#}

terraform {
  backend "s3" {
    bucket = "demo-eks-statefile"
    key    = "demo-eks-cluster"
    region = "us-east-1"
  }
}
module "eks" {
  source = "./modules/eks"

  aws-region              = "us-east-1"
  availability-zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cluster-name            = "demo-cluster"
  k8s-version             = "1.18"
  node-instance-type      = "t3a.medium"
  desired-capacity        = 3
  max-size                = 5
  min-size                = 1
  vpc-subnet-cidr         = "10.0.0.0/16"
  private-subnet-cidr     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public-subnet-cidr      = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  db-subnet-cidr          = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]
  eks-cw-logging          = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  ec2-key-public-key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3eu309AegkvCs2LIm7NMKkTGJGZ096AOd2EuBMS3uJkxFP7XTCmpOheJ1qUSNg3vv3xFQDRftO9i4N007Hal0VHN6SCGLWOU6SXoW5fduFsHnpCJ4/VRfkgtyOrLomxPaN53CkJTxlHSeGUno6vpa4XPa+FJqbRG3uhNzG8NADqF4Ll+JA66DihlFWKjzJxNosaelKMb/67l5XeHc6Fg1Al8YNomFDFU3rGD6TwE0veE40+MdzIzkNhlByq4rCVdc/Adre6vU2bmFGlfip6P26qNj7mkVinatM7AqIvPWq0eFzhTpXWFnHbUj7qa3wXfBihHmAcbj8K7jvQ6v54Bf root@ip-172-31-68-42.ec2.internal"
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}
