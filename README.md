**# AWS Project 1 — Secure, Scalable Web Application with Terraform**



\*\*Live application:\*\* https://project1.cloudbycliff.com



**##** **Project Overview**



I built a multi-tier AWS web application, starting with manually configured cloud infrastructure and transitioning it to Infrastructure as Code using Terraform.



The application runs on two private EC2 instances behind an Application Load Balancer, connects to a private PostgreSQL database hosted on Amazon RDS, and uses Amazon S3 for automated application deployment.



I configured Route 53 DNS, an AWS Certificate Manager TLS certificate, HTTPS, and automatic HTTP-to-HTTPS redirection.



**## Architecture**



\*\*Internet Users\*\*  

↓  

\*\*Amazon Route 53 — Custom Domain\*\*  

↓  

\*\*Application Load Balancer — HTTPS Port 443\*\*  

↓  

\*\*Auto Scaling Group — Two Private EC2 Instances\*\*  

↓  

\*\*Node.js / Express Application — Port 3000\*\*  

↓  

\*\*Amazon RDS PostgreSQL — Port 5432\*\*



**Supporting services**:



\- \*\*Amazon S3:\*\* Stores the packaged Node.js application.

\- \*\*AWS Systems Manager:\*\* Provides private server access and application configuration.

\- \*\*IAM:\*\* Controls access to AWS resources.

\- \*\*VPC endpoints:\*\* Support private connections to AWS services.

\- \*\*Terraform:\*\* Manages the infrastructure.

\- \*\*GitHub:\*\* Stores infrastructure code and change history.



**## Key Engineering Challenges**



**###** 1. **HTTP Worked, but HTTPS Failed**



\*\*Problem:\*\* During my initial manual build, the application would not load when I entered its address using `https://`. Removing the \*\*s\*\* and using `http://` allowed the application to load.



\*\*Root cause:\*\* The Application Load Balancer was configured for HTTP on port 80 but did not yet have a TLS certificate and HTTPS listener on port 443.



\*\*Solution:\*\* I used Terraform to configure AWS Certificate Manager, Route 53 DNS validation, an HTTPS listener, and the necessary security group rule. I also configured the HTTP listener to redirect requests to HTTPS.



\*\*Verified result:\*\* The application loaded securely at `https://project1.cloudbycliff.com`, and HTTP requests returned a `301 Moved Permanently` redirect to HTTPS.



\*\*Lesson learned:\*\* Application availability and transport security are separate concerns. A functional web application still requires correctly configured certificates, listeners, DNS, and networking.



**###** 2. **Automating Application Deployment to New EC2 Instances**



\*\*Problem:\*\* The original EC2 application servers required manual application preparation. I needed newly launched servers to install the application automatically.



\*\*Solution:\*\* I packaged the Node.js application with its dependencies in a private S3 bucket and configured EC2 startup automation through Launch Template version 3.



Before changing the live servers, I launched a temporary EC2 instance to test version 3 independently.



\*\*Verified result:\*\* The temporary server downloaded the application from S3, started the Node.js systemd service, and returned a healthy application response. Its startup log reported `PROJECT1\_APP\_READY`.



I then performed an Auto Scaling Instance Refresh to replace the existing servers with the tested version.



\*\*Production result:\*\* Both replacement EC2 instances were healthy and used Launch Template version 3.



\*\*Lesson learned:\*\* Test new server configurations independently before rolling them into production infrastructure.



**###** 3. **Converting Existing AWS Infrastructure to Terraform**



\*\*Problem:\*\* My original AWS infrastructure had been created manually, and bringing it under Terraform management introduced configuration differences that could have caused unwanted resource replacement.



\*\*Solution:\*\* I imported existing resources into Terraform state, reviewed plans, corrected mismatches, and applied controlled infrastructure updates.



\*\*Lesson learned:\*\* Infrastructure as Code requires careful state management and review, particularly when adopting existing resources.





**##** **Final Integration Tests**



| Component | Actual Verified Result |

|---|---|

| HTTPS application | Healthy |

| HTTP-to-HTTPS redirection | HTTP 301 |

| EC2 Auto Scaling | Two healthy instances, Launch Template v3 |

| Application Load Balancer | Two healthy targets |

| RDS PostgreSQL | Available |

| S3 application package | Verified present |

| Terraform deployment | Successful |

| GitHub version control | Commits successfully pushed |



**##** **Technical Skills Demonstrated**



\- AWS VPC networking and private subnets

\- EC2 and Auto Scaling Groups

\- Application Load Balancing and health checks

\- PostgreSQL on Amazon RDS

\- IAM and least-privilege application permissions

\- Amazon S3 application storage

\- EC2 user-data deployment automation

\- AWS Systems Manager

\- Terraform resource imports and state management

\- Route 53, ACM certificates, TLS, and HTTPS

\- Git and GitHub version control

\- AWS CLI troubleshooting



**##** **Implementation Notes**



The external browser connection is protected by HTTPS at the Application Load Balancer. Traffic from the load balancer to the private Node.js instances uses HTTP on port 3000.



New EC2 instances retrieve the application package from S3 during startup.



Terraform manages the cloud infrastructure, and GitHub stores the infrastructure source code. A GitHub Actions CI/CD pipeline is not currently configured.



Terraform state, application secrets, and private credentials are not intended for publication in this repository.



**##** **Project Outcome**



This project demonstrates my hands-on experience in AWS engineering, cloud architecture, infrastructure automation, secure application delivery, and troubleshooting.



The focus was not simply launching an application. It was understanding the components, validating infrastructure changes safely, resolving real configuration issues, and documenting the engineering decisions behind the working system.

