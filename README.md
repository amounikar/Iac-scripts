# terraform-eks-pipeline
A reusable pipeline template to apply terraform configuration serially across multiple environments.

# commands to execute the terraform script manually 
 You have a separate terraform project that can be run with the following commands:
    1.  `terraform init`
    2.  `terraform plan`
    3.  `terraform apply`

# How to Use
1.  Create a Jenkinsfile in your terraform project 
```
// Jenkinsfile
@Library(['k8s-agent@master']) _
```
2.  Provide terraform-pipeline with a reference to the Jenkinsfile context, so it can do all of it's magic under the hood.
```
// Jenkinsfile
...
pipeline {

    agent {
    kubernetes(k8sagent(name: 'mini+terraform'))
  }
options
    {
        buildDiscarder(logRotator(numToKeepStr: '3'))
    }
      environment 
    {
        CRD = ''
    }
  stages {

    
         
   stage('Terraform init'){
       steps {
            container('terraform') {
                
                // Initialize the plan 
                sh  """
                    export TF_LOG=TRACE
                    terraform init -input=false
                   """
                }
            }
        }

stage('Terraform plan'){
    steps {
            container('terraform') {  
                
                sh "terraform plan -out=tfplan -input=false"
                
                //sh (script:"cd terraform-plans/create-vmss-from-image && terraform plan -out=tfplan -input=false -var 'terraform_resource_group='$vmss_rg -var 'terraform_vmss_name='$vmss_name -var 'terraform_azure_region='$location -var 'terraform_image_id='$image_id")
                }      
            }
        }
       
        stage('Terraform apply'){
            steps {
            container('terraform') {
                
                // Apply the plan
                sh  """  
                   echo "terraform apply"
                    terraform apply -input=false -auto-approve "tfplan"
                   """
                }
            }
        }
        
    }

} 
```

2.  Create deployment Stages for each of the environments that you would normally deploy to.  This example creates terraform resources for qa, uat, and prod environments.  The number and names of your environments can differ from this example.  Choose the environments and environment names that reflect your own development process to go from Code to Customer. Pass all the required arguments in the module file to provision an eks cluster. 
```
dev-cluster.tf
===============
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
  cluster-name            = "demo-cluster-dev"
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
  ec2-key-public-key      = ""
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}
```

