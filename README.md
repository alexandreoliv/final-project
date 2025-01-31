# Final Project: End-to-End DevOps Deployment

## Project Overview :pencil2:

This project demonstrates the complete DevOps cycle for deploying a scalable Expense Tracker application. It integrates infrastructure automation, container orchestration, CI/CD pipelines, monitoring, and autoscaling best practices.

## Key Features :notebook:

By the end of this project, the following objectives were accomplished:

1. **Infrastructure as Code (IaC)** using Terraform to provision AWS resources.
2. **CI/CD Pipeline** built with GitHub Actions to automate application deployment.
3. **Containerization & Orchestration** using Docker and Kubernetes on AWS EKS.
4. **Scalability & Autoscaling** with Kubernetes Horizontal Pod Autoscaler (HPA) and AWS Auto Scaling.
5. **Monitoring & Logging** using Prometheus, Grafana, and CloudWatch.
6. **Security & Compliance** through IAM policies, role-based access control (RBAC), and best security practices.

## Project Architecture (a sample application, cloned from an existing repo)

The Expense Tracker application consists of the following microservices:
- **Frontend**: Built with Next.js, deployed as a Kubernetes deployment.
- **Backend**: Node.js service, managing business logic.
- **MongoDB**: NoSQL database for persistent storage.
- **Redis**: Caching layer for performance optimization.

## Infrastructure Setup (developed exclusively for this final project)

### AWS Resources Provisioned via Terraform:
- **VPC** with public and private subnets.
- **EKS Cluster** with managed node groups.
- **Application Load Balancer (ALB)** for ingress routing.
- **EBS Persistent Volumes** for MongoDB.
- **IAM Roles & Policies** for ALB and EBS.
- **Autoscaling Groups** with CPU and memory-based scaling policies.
- **CloudWatch Alarms** for monitoring memory utilization.

### Terraform Files:
- `alb.tf`: Configures the AWS ALB and IAM policies.
- `ebs.tf`: Manages EBS storage and IAM roles.
- `main.tf`: Defines the AWS provider, VPC, and EKS cluster.
- `metrics.tf`: Deploys Kubernetes Metrics Server.
- `monitoring.tf`: Sets up Prometheus and Grafana via Helm.

## Kubernetes Configuration

The following Kubernetes manifests were deployed:
- **Deployments**: `frontend`, `backend`, `redis`, `mongo`
- **Services**: `frontend-service`, `backend-service`, `mongo-service`, `redis-service`
- **Ingress Controllers**: Configured with AWS ALB - for frontend, Prometheus and Grafana
- **Persistent Volumes**: Storage for MongoDB
- **ConfigMaps & Secrets**: Environment variable management
- **Autoscaler**: HorizontalPodAutoscaler (HPA) for frontend and backend
- **Monitoring**: Prometheus and Grafana ingress

## CI/CD Pipeline

The GitHub Actions workflow automates deployment:
- **Triggers on push/pull requests** to the `main` branch.
- **Builds Docker images** after code changes, automatically incrementing the version tag.
- **Pushes container images** to DockerHub.
- **Deploys infrastructure** using Terraform.
- **Deploys application** to AWS EKS.

## Monitoring & Logging
- **Prometheus & Grafana** for real-time metrics.
- **CloudWatch Alarms** to track resource utilization.
- **AWS ALB logs** for network traffic analysis.

## Autoscaling Implementation
- **Kubernetes HPA** scales pods based on CPU utilization.
- **AWS Auto Scaling** adds/removes EC2 nodes dynamically.
- **CloudWatch Alarms** trigger scaling policies based on memory usage.

## Security & Compliance
- **IAM Roles** for least privilege access.
- **RBAC** in Kubernetes to restrict permissions.
- **Encrypted storage** for Terraform state file on S3.

## Deployment Instructions
1. **Make Changes**:
   Modify the Terraform configuration files, Kubernetes resources, or code in the frontend or backend apps.

2. **Push Changes**:
   Push or create a pull request to the main branch.

3. **CI/CD Trigger**:
   The CI/CD pipeline will automatically trigger and deploy the changes.

## Conclusion
This project successfully implements a complete DevOps pipeline with cloud infrastructure automation, container orchestration, CI/CD, monitoring, and security best practices, ensuring a scalable and production-ready deployment of the Expense Tracker application.

**Project Completed Successfully!** 🚀