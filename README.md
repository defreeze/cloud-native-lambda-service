# Cloud-Native Lambda Service

memo2 test assignment

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
### There are just tests and are stored as github Actions keys
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
