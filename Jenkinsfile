pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-2'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out Terraform code...'
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                echo '🔧 Initializing Terraform...'
                sh 'terraform init -reconfigure'
            }
        }

        stage('Terraform Validate') {
            steps {
                echo '✅ Validating Terraform configuration...'
                sh 'terraform validate'
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo '📝 Checking Terraform formatting...'
                sh 'terraform fmt -check -recursive || echo "Warning: Some files need formatting"'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo '📋 Creating Terraform plan...'
                sh 'terraform plan -out=tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
                archiveArtifacts artifacts: 'tfplan.txt', fingerprint: true
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀 Applying Terraform configuration...'
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Output Infrastructure Info') {
            when {
                branch 'main'
            }
            steps {
                echo '📊 Retrieving infrastructure outputs...'
                script {
                    sh 'terraform output -json > terraform-outputs.json'
                    archiveArtifacts artifacts: 'terraform-outputs.json', fingerprint: true

                    // Display important outputs
                    def outputs = sh(
                        script: 'terraform output -json',
                        returnStdout: true
                    )
                    echo "Infrastructure Outputs:\n${outputs}"
                }
            }
        }

        stage('Verify EC2 Instances') {
            when {
                branch 'main'
            }
            steps {
                echo '🔍 Verifying EC2 instances are running...'
                sh '''
                    aws ec2 describe-instances \
                        --filters "Name=instance-state-name,Values=running" \
                        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
                        --output table
                '''
            }
        }
    }

    post {
        always {
            echo '📊 Infrastructure pipeline finished'
            // Clean up plan file
            sh 'rm -f tfplan tfplan.txt || true'
        }
        success {
            echo '✅ Infrastructure deployment successful'
        }
        failure {
            echo '❌ Infrastructure deployment failed'
        }
    }
}
