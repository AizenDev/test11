pipeline {
    agent any
    
    tools {
        terraform 'terraform'
    }
    
    environment {
        GCP_CREDENTIALS_ID = '053b92bf-55b6-4ede-a9ed-d7f0c4aa30ff'
        GCP_PROJECT = 'xenon-pier-459606-n2'
        GCP_REGION = 'europe-north1'
        SSH_PUB_KEY_ID = 'd1de2818-75f0-41c1-bfa1-d0ab00bbb98d'
        SSH_PRIVATE_KEY = 'c155c60d-112f-4cfe-8f55-21e496d73375'
        DOCKERHUB_CREDS = 'bcb75d6f-20dc-44c9-be45-d49984ea66c4'
    }
    
    stages {
        stage ("test") {
            steps {
                sh 'terraform --version'
            }
        }
        
        stage ("Clone project") {
            steps {
                git branch: 'main', credentialsId: '98b6c89a-355d-412f-8827-1d250e243480', url: 'https://github.com/AizenDev/test11.git'
            }
        }
        
        stage ("Apply terraform manifest") {
            steps {
                sh 'terraform --version'

                dir('/var/lib/jenkins/workspace/new1/tf') {
                withCredentials([
                    file(credentialsId: GCP_CREDENTIALS_ID, variable: 'GCP_KEY_FILE'),
                    file(credentialsId: SSH_PUB_KEY_ID, variable: 'SSH_PUB_KEY')
                ]) {
                        sh '''
                            cat \"$SSH_PUB_KEY\"
                            export GOOGLE_APPLICATION_CREDENTIALS="$GCP_KEY_FILE"
                            terraform init
                            terraform apply -auto-approve -var="ssh_public_key=$(cat \"$SSH_PUB_KEY\")"
                        '''
                    }
                }
            }
        }
        
        stage('Save IP in vars') {
            steps {
                dir('/var/lib/jenkins/workspace/new1/tf'){
                    script {
                        builder_ip   = sh(script: 'terraform output -raw instance_ip_1',   returnStdout: true).trim()
                        deployer_ip  = sh(script: 'terraform output -raw instance_ip_2',  returnStdout: true).trim()
                        
                        env.BUILDER_IP  = builder_ip
                        env.DEPLOYER_IP = deployer_ip
                    }
                }
            }
        }
        
        
        stage('Wait for SSH Availability') {
            steps {
                
                script {
                    waitForSsh(env.BUILDER_IP)
                    waitForSsh(env.DEPLOYER_IP)
                }
            }
        }
        
        
        stage('Make inventory') {
              steps {
                  dir('/var/lib/jenkins/workspace/new1/ans') {
                        script {
                          writeFile file: 'inventory.ini', text: """
                            [build-host]
                            ${env.BUILDER_IP}
                
                            [deploy-host]
                            ${env.BUILDER_IP}
                          """
                        }
                  }
            }
        }
        
        
        stage('Ansible: Build App on Builder') {
            steps {
                dir('/var/lib/jenkins/workspace/new1/ans') {
                    withCredentials([
                            usernamePassword(credentialsId: DOCKERHUB_CREDS, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD'),
                            sshUserPrivateKey(credentialsId: 'c155c60d-112f-4cfe-8f55-21e496d73375', keyFileVariable: 'SSH_PR', usernameVariable: 'SSH_USER')
                        ]) {
                        sh """
                            ansible-playbook -u root -i 'inventory.ini' build-book.yaml \
                                --private-key ${SSH_PR} \
                                -e "dockerhub_password=${DOCKER_PASSWORD}"
                        """
                    }
                }
            }
        }
        
        stage('Ansible: Deploy to Deployer') {
            steps {
                dir('/var/lib/jenkins/workspace/new1/ans') {
                    withCredentials([
                            usernamePassword(credentialsId: DOCKERHUB_CREDS, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD'),
                            sshUserPrivateKey(credentialsId: 'c155c60d-112f-4cfe-8f55-21e496d73375', keyFileVariable: 'SSH_PR', usernameVariable: 'SSH_USER')
                        ]) {
                        sh """
                            ansible-playbook -u root -i 'inventory.ini' deploy-book.yaml \
                                --private-key ${SSH_PR} \
                                -e "dockerhub_password=${DOCKER_PASSWORD}"
                        """
                    }
                }
            }
        }
        
        
        
    }
}

void waitForSsh(String ip, int port = 22, int timeout = 120) {
    int timeWaited = 0
    while(timeWaited < timeout) {
        try {
            sh "nc -z -w5 ${ip} ${port}"
            echo "SSH на ${ip} доступен"
            return
        } catch(e) {
            sleep(10)
            timeWaited += 10
        }
    }
    error("Таймаут подключения к ${ip} по SSH")
}
