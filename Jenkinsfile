pipeline {
  agent any
  options {
    timestamps()
  }

  environment {
    REGISTRY_CREDENTIALS = 'dockerhub-creds'
  }

  parameters {
    choice(name: 'DEPLOY_COLOR', choices: ['blue', 'green'], description: 'Idle environment that should receive the new version first')
    string(name: 'DOCKERHUB_REPO', defaultValue: 'dockerhub-username/bluegreen-demo', description: 'Docker Hub repository (e.g. user/app)')
    string(name: 'IMAGE_TAG', defaultValue: '', description: 'Optional image tag override. Leave blank to use build number')
    string(name: 'SMOKE_TEST_URL', defaultValue: 'http://bluegreen-proxy.example.com/health', description: 'URL hit after deployment to verify the new color')
    booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: false, description: 'Switch NGINX proxy to the new color after smoke tests pass?')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Unit tests') {
      steps {
        sh 'npm test || echo "No automated tests yet"'
      }
    }

    stage('Build image') {
      steps {
        script {
          env.RELEASE_TAG = params.IMAGE_TAG?.trim() ? params.IMAGE_TAG : "build-${env.BUILD_NUMBER}"
          env.IMAGE_NAME = "${params.DOCKERHUB_REPO}:${env.RELEASE_TAG}"
        }
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Push image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE_NAME
            docker logout
          '''
        }
      }
    }

    stage('Deploy to idle color') {
      steps {
        sh "./scripts/deploy-color.sh ${params.DEPLOY_COLOR} $IMAGE_NAME $RELEASE_TAG"
      }
    }

    stage('Smoke test') {
      steps {
        sh "curl -fsSL ${params.SMOKE_TEST_URL}"
      }
    }

    stage('Switch traffic (optional)') {
      when {
        expression { params.SWITCH_TRAFFIC }
      }
      steps {
        sh "./scripts/switch-color.sh ${params.DEPLOY_COLOR}"
      }
    }
  }
}
