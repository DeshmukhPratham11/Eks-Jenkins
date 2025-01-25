data "aws_subnets" "available_subnet"{
    filter {
        name = "tag:Name"
        values = ["BlueDart-Public-*"]
    }
}   

resource "aws_eks_cluster" "BlueDart_cluster"{
    name = "BlueDart-Cluster"
    role_arn = aws_iam_role.example.arn

    vpc_config {
      subnet_ids = data.aws_subnets.available_subnet.ids
    }

    depends_on = [
        aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
        aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    ]
}

output "endpoint" {
    value = aws_eks_cluster.BlueDart_cluster.endpoint
}

output "kubeconfig-certificate-authority-data"{
    value = aws_eks_cluster.BlueDart_cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "BlueDart-node-grp" {
  cluster_name    = aws_eks_cluster.BlueDart_cluster.name
  node_group_name = "BlueDart-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = data.aws_subnets.available_subnet.ids
  capacity_type   = "ON_DEMAND"
  disk_size       = "20"
  instance_types  = ["t2.micro"]
  labels = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
    ]  
}