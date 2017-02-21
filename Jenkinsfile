pipeline {
  agent none

  environment {
    IMAGE_NAME = 'prydonius/node-todo'
    HELM_URL = 'https://storage.googleapis.com/kubernetes-helm'
    HELM_TARBALL = 'helm-v2.2.0-linux-amd64.tar.gz'
  }

  stages {
    stage('Build') {
      agent any

      steps {
        checkout scm
        sh 'docker build -t $IMAGE_NAME:$BUILD_ID .'
      }
    }
    stage('Test') {
      agent any

      steps {
        echo 'TODO: add tests'
      }
    }
    stage('Image Release') {
      agent any

      when {
        expression { env.BRANCH_NAME == 'master' }
      }

      steps {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub',
          usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]) {
          sh '''
            docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
            docker push $IMAGE_NAME:$BUILD_ID
          '''
        }
      }
    }
    stage('Staging Deployment') {
      agent any

      when {
        expression { env.BRANCH_NAME == 'master' }
      }

      environment {
        RELEASE_NAME = 'todos-staging'
        SERVER_HOST = 'todos.staging.k8s.prydoni.us'
      }

      steps {
        sh '''
          curl -O $HELM_URL/$HELM_TARBALL
          tar xzfv $HELM_TARBALL -C /home/jenkins && rm $HELM_TARBALL
          PATH=/home/jenkins/linux-amd64/:$PATH
          helm init --client-only

          helm dependencies build ./helm/todo
          helm upgrade $RELEASE_NAME ./helm/todo --set image.tag=$BUILD_ID,ingress.host=$SERVER_HOST
        '''
      }
    }
    stage('Deploy to Production?') {
      when {
        expression { env.BRANCH_NAME == 'master' }
      }

      steps {
        input 'Deploy to Production?'
        // Prevent any older builds from deploying to production
        milestone(1)
      }
    }
    stage('Production Deployment') {
      agent any

      when {
        expression { env.BRANCH_NAME == 'master' }
      }

      environment {
        RELEASE_NAME = 'todos-production'
        SERVER_HOST = 'todos.k8s.prydoni.us'
      }

      steps {
        sh '''
          curl -O $HELM_URL/$HELM_TARBALL
          tar xzfv $HELM_TARBALL -C /home/jenkins && rm $HELM_TARBALL
          PATH=/home/jenkins/linux-amd64/:$PATH
          helm init --client-only

          helm dependencies build ./helm/todo
          helm upgrade $RELEASE_NAME ./helm/todo --set image.tag=$BUILD_ID,ingress.host=$SERVER_HOST
        '''
      }
    }
  }
}
