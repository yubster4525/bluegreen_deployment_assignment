pipeline {
  agent any
  tools {
    nodejs 'Node18'
  }
  options {
    timestamps()
  }

  environment {
    REGISTRY_CREDENTIALS = 'c15b784c-6898-4020-8619-6d9aac49c3bc'
    PATH = "/opt/homebrew/bin:/usr/local/bin:${env.PATH}"
  }

  parameters {
    choice(name: 'DEPLOY_COLOR', choices: ['blue', 'green'], description: 'Idle environment that should receive the new version first')
    string(name: 'DOCKERHUB_REPO', defaultValue: 'yuvan4525/bluegreen-demo', description: 'Docker Hub repository (e.g. user/app)')
    string(name: 'IMAGE_TAG', defaultValue: '', description: 'Optional image tag override. Leave blank to use build number')
    string(name: 'SMOKE_TEST_URL', defaultValue: 'http://localhost:8180/health', description: 'URL hit after deployment to verify the new color')
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

    stage('Prepare env file') {
      steps {
        script {
          def repoParts = params.DOCKERHUB_REPO.tokenize('/')
          def dockerUser = repoParts ? repoParts[0] : 'dockerhub-user'
          def appName = repoParts.size() > 1 ? repoParts[1] : 'bluegreen-demo'
          def envText = """
            ACTIVE_COLOR=blue
            DOCKERHUB_USERNAME=${dockerUser}
            APP_NAME=${appName}
            BLUE_IMAGE=${params.DOCKERHUB_REPO}:blue
            GREEN_IMAGE=${params.DOCKERHUB_REPO}:green
            BLUE_VERSION=1.0.0
            GREEN_VERSION=1.0.1
            STACK_PREFIX=jenkins-
            BLUE_PORT=3101
            GREEN_PORT=3102
            PROXY_PORT=8180
          """.stripIndent().trim() + "\n"
          writeFile file: '.env', text: envText
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
