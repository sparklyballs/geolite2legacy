pipeline {
	agent {
	label 'DOCKER_BUILD_X86_64'
	}

options {
	skipDefaultCheckout(true)
	buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
	}

environment {
	CREDS_DOCKERHUB=credentials('420d305d-4feb-4f56-802b-a3382c561226')
	CREDS_GITHUB=credentials('bd8b00ff-decf-4a75-9e56-1ea2c7d0d708')
	CONTAINER_NAME = 'geolite2legacy'
	CONTAINER_REPOSITORY = 'sparklyballs/geolite2legacy'
	GITHUB_REPOSITORY = 'sparklyballs/geolite2legacy'
	HADOLINT_OPTIONS = '--ignore DL3008 --ignore DL3013 --ignore DL3018 --ignore DL3028 --format json'
	MAXMIND_CREDENTIALS=credentials('50780129-e7b2-46fe-9e53-1e90efdd2ed7')
	}

stages {

stage('Checkout Repository') {
steps {
	cleanWs()
	checkout scm
	}
	}

stage ("Do Some Linting") {
steps {
	sh ('curl -o linting-script.sh -L https://raw.githubusercontent.com/sparklyballs/versioning/master/linting-script.sh')
	sh ('/bin/bash linting-script.sh')
	recordIssues enabledForFailure: true, tool: hadoLint(pattern: 'hadolint-result.xml')	
	recordIssues enabledForFailure: true, tool: checkStyle(pattern: 'shellcheck-result.xml')	
	}
	}

stage('Build Docker Image') {
steps {
	sh ('docker buildx build \
	--no-cache \
	--pull \
	-t $CONTAINER_REPOSITORY:$BUILD_NUMBER \
	.')
	}
	}

stage('Create GeoIP.dat) {
steps {
	sh('mkdir -p $WORKSPACE/build')
	sh('curl -o $WORKSPACE/build/GeoLite2-Country-CSV.zip -L \
	"https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${MAXMIND_CREDENTIALS}&suffix=zip"')
	sh('docker run \
	--rm=true -i -v \
	$WORKSPACE/build:/src geolite2legacy:${BUILD_NUMBER} \
	-i /src/GeoLite2-Country-CSV.zip -o /src/GeoIP.dat')
	}
	}
	
post {
success {
archiveArtifacts artifacts: 'build/GeoIP.dat'
	}
	}
}
}
