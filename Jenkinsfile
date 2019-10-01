node('6.0') {

    stage('Checkout SCM') {
        checkout scm
    }

    stage('Build containers') {
        sh 'docker build -t openjpeg - < ./Dockerfile.ubuntu'
        sh 'docker build -t openjpeg_emscripten - < Dockerfile.emscripten'
    }

    stage('Build openjpeg') {
        sh 'docker run --rm -v $(pwd):/workdir -e BRANCH_NAME -e GIT_COMMIT -e JOB_NAME -e BUILD_NUMBER openjpeg'
    }

    stage('Build openjpeg emscripten') {
        sh 'docker run --rm -v $(pwd):/workdir -e BRANCH_NAME -e GIT_COMMIT -e JOB_NAME -e BUILD_NUMBER openjpeg_emscripten'
    }

    stage('package and publish') {
        timeout(time: 15, unit: 'MINUTES') {
            sh "git rev-parse HEAD > .git_commit"
            env.GIT_BRANCH = "${env.BRANCH_NAME}"
            env.GIT_COMMIT = readFile('.git_commit')
            step([
                $class: 'S3BucketPublisher',
                consoleLogLevel: 'INFO',
                dontWaitForConcurrentBuildCompletion: false,
                entries: [[
                    bucket: "morpheus-builds/openjpeg/${env.GIT_BRANCH}",
                    excludedFile: '',
                    flatten: false,
                    gzipFiles: false,
                    keepForever: true,
                    managedArtifacts: false,
                    noUploadOnFailure: true,
                    selectedRegion: 'us-west-2',
                    showDirectlyInBrowser: false,
                    sourceFile: 'artifacts/*.tgz',
                    storageClass: 'STANDARD',
                    uploadFromSlave: true,
                    useServerSideEncryption: true
                ]],
                pluginFailureResultConstraint: 'FAILURE',
                profileName: 'jenkins-morpheusimaging',
                userMetadata: [
                    [key: 'git-branch', value: "${env.GIT_BRANCH}"],
                    [key: 'git-commit', value: "${env.GIT_COMMIT}"],
                    [key: 'build-tag', value: "${env.BUILD_TAG}"],
                    [key: 'build-node', value: "${env.NODE_NAME}"]
                ]
            ])
        }
    }
}
