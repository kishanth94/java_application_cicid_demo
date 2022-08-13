pipeline{
    agent any
    
    stages{
        stage("Git Checkout"){
            steps{
                git credentialsId: 'github', url: 'https://github.com/kishanth94/java_application_cicid_demo/'
            }
        }
	
        stage('Quality Gate Status Check'){
            steps{
                script{
			withSonarQubeEnv(credentialsId: 'sonar-token') { 
                        // Get Home Path of Maven 
                        def mvnHome = tool name: 'maven-3', type: 'maven'
			sh "${mvnHome}/bin/mvn clean sonar:sonar"
                       	  }
			            timeout(time: 20, unit: 'SECONDS') {
			            def qg = waitForQualityGate()
				                if (qg.status != 'OK') {
					                 error "Pipeline aborted due to quality gate failure: ${qg.status}"
				                }
                          }
                }
            }  
        }
	
	
        stage("Maven Build"){
            steps{
                script{
                // Get Home Path of Maven 
                def mvnHome = tool name: 'maven-3', type: 'maven'
                sh "${mvnHome}/bin/mvn clean package"
                }
            }
        }
	
	
	stage("Upload War To Nexus"){
	    steps{
		script{
		    def mavenPom = readMavenPom file: 'pom.xml'
		    def nexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "SimpleJavaProject-snapshot" : "SimpleJavaProject-release"
		    nexusArtifactUploader artifacts: [
			[
			    artifactId: 'SimpleJavaProject', 
		            classifier: '', 
			    file: "target/SimpleJavaProject-${mavenPom.version}.war", 
			    type: 'war'
			]
			], 
			    credentialsId: 'nexus3', 
			    groupId: 'com.adevguide.java', 
			    nexusUrl: '172.31.25.143:8081', 
			    nexusVersion: 'nexus3', 
			    protocol: 'http', 
			    repository: nexusRepoName, 
			    version: "${mavenPom.version}"    
                       }
		}
	}
	
	    
        stage("Deploy to Tomcat Server"){
            steps{
                sshagent(['tomcat-keypair']) {
                sh """
		    echo $WORKSPACE
		    mv target/*.war target/SimpleJavaProject.war
                    scp -o StrictHostKeyChecking=no target/SimpleJavaProject.war  ec2-user@172.31.42.91:/opt/tomcat8/webapps/
                    ssh ec2-user@172.31.42.91 /opt/tomcat8/bin/shutdown.sh
                    ssh ec2-user@172.31.42.91 /opt/tomcat8/bin/startup.sh
                
                """
                }
            
            }
        }
    }  
	
    post {
	    always {
	      echo 'Deleting the Workspace'
	      deleteDir() /* Clean Up our Workspace */
	    }
	    success {
		mail to: 'kishanthisavailable@gmail.com',
		   subject: "Success Build Pipeline: ${currentBuild.fullDisplayName}",
		    body: "The pipeline ${env.BUILD_URL} completed successfully"
	    }
	    failure {
  		mail to: 'kishanthisavailable@gmail.com',
 		     subject: "Failed Build Pipeline: ${currentBuild.fullDisplayName}",
 		     body: "Something is wrong with ${env.BUILD_URL}"
 	    }
    }
}
