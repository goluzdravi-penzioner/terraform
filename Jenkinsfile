node('k8s-slave') {
    stage('terraform-install') {
        git([url: 'https://github.com/goluzdravi-penzioner/terraform.git', branch: 'master'])
        sh label: '', script: '''#!/bin/bash
        wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
        unzip terraform_0.11.11_linux_amd64.zip
        chmod +x terraform'''
}
    stage('terraform-init') {
        sh label: '', script: './terraform init'
}
    stage('terraform-validate') {
        withEnv(["AWS_DEFAULT_REGION=us-east-1"]) {
        sh label: '', script: './terraform validate'
        }
    }
    stage('terraform-plan-apply') {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'rnd',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh label: '', script: './terraform plan'
          sh label: '', script: './terraform apply -auto-approve'
        }
    }
    cleanWs()
}
