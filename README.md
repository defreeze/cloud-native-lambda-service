# Cloud-Native Lambda Service

memo2 test assignment
Alex de Vries

The assessment consists of two main steps, first the two REST endpoints using Terraform for provisioning. The second step is setting up a CI/CD pipeline for Github Actions.

My approach is similar to the order of the CI/CD steps. First I install node.js,  terraform and all other dependencies.

Then I worked on index.ts for defining the two endpoints. I used this AWS documentation as reference: https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html

Then i started working on terraform for the files main.tf for the infra code, iam.tf for the IAM roles, ssm.tf for parameter store and variables.tf which is not too relevant here but useful for production. The cloudwatch alarm goes of if there is more than 1 error within a 300 second time window. This was my main source: https://registry.terraform.io/providers/hashicorp/aws/latest/docs.

Lastly i Worked on the ci/cd pipeline in ci.yml. For this I commented out the terraform apply as there is no real AWS connection and the keys are just for the test.

Things to improve for production:
- api gateway authentication
- rate limits on api endpoints
- add logging of api calls to a database
- more cloudeatch alarms such as errors
- seperate dev/staging/prod (now its just all in the main branch).
- improve code comments and a real connection to AWS

## Features
- GET /health → Returns service health status
- POST /echo → Echoes back the request body
- CI/CD with GitHub Actions


### Local Development
```bash
npm install
npm run dev
npm test
```

Local endpoints:
- http://localhost:4000/dev/health
- http://localhost:4000/dev/echo

### Deployment
```bash
npm run deploy
npm run deploy:prod
```

## Configuration

### Environment Variables
### These are just tests and are stored as github Actions keys
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `API_KEY`: Service API key


## CI/CD Pipeline steps
GitHub Actions workflow:
1. Lint & Test
2. Build (only for prod)
3. Deploy (only for prod)

Secrets managed via GitHub Secrets.

## demo test for memo2
```bash
npm run dev
```
- go to postman and use the following info for testing the server:
Health Check Endpoint
Method: GET
URL: http://localhost:5000/dev/health
Headers: None required
Body: None required


2. Echo Endpoint
Method: POST
URL: http://localhost:5000/dev/echo
Headers:
Content-Type: application/json
Body: Raw JSON, example
{
    "message": "Hello, Lambda!"
}
