# Cloud-Native Lambda Service

This project demonstrates a cloud-native microservice architecture using AWS Lambda and API Gateway, provisioned with Infrastructure as Code (IaC).

## Architecture Overview

The service provides two REST endpoints:
- `GET /health` - Returns service health status
- `POST /echo` - Echoes back the request body

### Key Components

1. **AWS Lambda Function**: Node.js-based serverless function handling requests
2. **API Gateway**: REST API interface
3. **IAM Roles**: Least-privilege access for Lambda
4. **SSM Parameter Store**: Secure storage for configuration
5. **CloudWatch**: Logging and monitoring (optional)

## Technology Choices

- **IaC**: Terraform
  - Why: Mature ecosystem, excellent documentation, and provider support
  - HashiCorp Configuration Language (HCL) is declarative and readable
  
- **Runtime**: Node.js
  - Why: Lightweight, fast cold starts, extensive ecosystem
  - TypeScript for type safety and better developer experience
  
- **CI/CD**: GitHub Actions
  - Why: Native GitHub integration, extensive marketplace
  - Easy secrets management via GitHub Secrets

## Local Development

### Prerequisites

1. Node.js 18+
2. Terraform 1.0+
3. AWS CLI (for deployment)

### Setup

```bash
# Install dependencies
npm install

# Run tests
npm test

# Local development server (uses serverless-offline)
npm run dev
```

### Testing

```bash
# Unit tests
npm run test:unit

# Integration tests (requires AWS credentials)
npm run test:integration
```

## Deployment

### Prerequisites

1. AWS credentials configured
2. GitHub repository secrets set:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

### Manual Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

## Cost Estimation

Monthly cost estimation based on 1M requests/month:

1. **AWS Lambda**
   - Free tier: 1M requests/month
   - Additional requests: $0.20 per 1M requests
   - Estimated cost: $0.00 (within free tier)

2. **API Gateway**
   - $3.50 per million API calls received
   - Estimated cost: $3.50

3. **CloudWatch Logs**
   - First 5GB free
   - $0.50 per GB ingested
   - Estimated cost: $0.00 (within free tier)

**Total Estimated Monthly Cost**: $3.50

## Monitoring & Alerting

### CloudWatch Setup

1. **Metrics Monitored**:
   - Lambda execution duration
   - Error rate
   - API Gateway 4xx/5xx errors
   - Integration latency

2. **Example Alert Rules**:
   - Error rate > 1% over 5 minutes
   - P95 latency > 1000ms
   - Any 5xx errors in 5-minute period

## Production Hardening

For production deployment, consider these additional measures:

1. **Security**:
   - Enable AWS WAF for API Gateway
   - Implement rate limiting
   - Add request validation
   - Use AWS X-Ray for tracing

2. **Reliability**:
   - Multi-region deployment
   - DynamoDB for state management
   - Circuit breakers for external dependencies

3. **Monitoring**:
   - Enhanced logging with structured JSON
   - Business metrics tracking
   - SLO/SLA monitoring

4. **CI/CD**:
   - Automated integration tests
   - Canary deployments
   - Automated rollbacks
   - Security scanning

## What Requires AWS Access

The following features require AWS access to implement:

1. **Actual Deployment**:
   - Lambda function creation
   - API Gateway setup
   - IAM role configuration
   - Parameter Store usage

2. **Testing**:
   - Integration tests against real AWS services
   - CloudWatch logs verification
   - API Gateway testing

3. **Monitoring**:
   - CloudWatch metrics
   - Alert rule configuration
   - Log analysis

Note: Local development and testing can still be done using mocks and local alternatives.

## License

MIT