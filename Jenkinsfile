pipeline{
    agent any
    
    stages{
        stage("Git Checkout"){
            steps{
                git credentialsId: 'github', url: 'https://github.com/kishanth94/javawebapplication'
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
		    def nexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "javawebapplication-snapshot" : "javawebapplication-release"
		    nexusArtifactUploader artifacts: [
			[
			    artifactId: 'javawebapplication', 
		            classifier: '', 
			    file: "target/javawebapplication-${mavenPom.version}.war", 
			    type: 'war'
			]
			], 
			    credentialsId: 'nexus3', 
			    groupId: 'in.javahome', 
			    nexusUrl: '172.31.45.236:8081', 
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
		    mv target/*.war target/javawebapplication.war
                    scp -o StrictHostKeyChecking=no target/javawebapplication.war  ec2-user@172.31.25.215:/opt/tomcat8/webapps/
                    ssh ec2-user@172.31.25.215 /opt/tomcat8/bin/shutdown.sh
                    ssh ec2-user@172.31.25.215 /opt/tomcat8/bin/startup.sh
                
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
	    //success {
		//mail to: 'devopsawsfreetier@gmail.com',
		     //subject: "Success Build Pipeline: ${currentBuild.fullDisplayName}",
		     //body: "The pipeline ${env.BUILD_URL} completed successfully"
	    //}
	    //failure {
//  		mail to: 'devopsawsfreetier@gmail.com',
// 		     subject: "Failed Build Pipeline: ${currentBuild.fullDisplayName}",
// 		     body: "Something is wrong with ${env.BUILD_URL}"
// 	    }
    }
}


