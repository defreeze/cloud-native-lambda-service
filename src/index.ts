import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const ssm = new SSMClient({
  region: process.env.AWS_REGION || 'us-east-1',
  ...(process.env.IS_OFFLINE === 'true' && {
    endpoint: 'http://localhost:4000',
    credentials: {
      accessKeyId: 'test',
      secretAccessKey: 'test'
    }
  })
});

export const healthHandler = async (): Promise<APIGatewayProxyResult> => {
  return {
    statusCode: 200,
    body: JSON.stringify({ status: 'ok' })
  };
};

export const echoHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    const body = event.body ? JSON.parse(event.body) : {};

    let apiKeyExists = false;
    if (process.env.IS_OFFLINE !== 'true' && process.env.NODE_ENV !== 'test') {
      try {
        const apiKeyParam = await ssm.send(
          new GetParameterCommand({
            Name: '/myapp/api-key',
            WithDecryption: true
          })
        );
        apiKeyExists = !!apiKeyParam.Parameter?.Value;
      } catch (ssmError) {
        console.warn('Could not access SSM:', ssmError);
      }
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Echo service responding (memo2 demo)',
        youSent: body,
        apiKeyExists
      })
    };
  } catch (error) {
    console.error('Error processing request:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};