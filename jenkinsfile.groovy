pipeline{
    agent any   

    parameters {
        choice(
            name : 'Action',
            choices : ['apply','destroy']
            description : 'Select choice to apply or destroy'
        )
    }

    stages{
        stage('Checkout'){
            steps {
                git "https://github.com/DeshmukhPratham11/Eks-Jenkins.git"
            }
        }

        stage('terraform init'){
            steps{
                sh "terraform init"
            }
        }

        stage('terraform plan'){
            steps{
                sh "terraform plan"
            }
        }

        stage('Action'){
            steps{
                script{
                    def ActionTaken = params.Action

                    if (ActionTaken == 'Apply'){
                        sh "terraform apply --auto-approve"
                    }
                    else if (ActionTaken == 'Destroy'){
                        sh "terraform destroy --auto-approve"
                    }
                }  
            }
        }

    }
    

}