import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const ssm = new SSMClient({});

export const healthHandler = async (): Promise<APIGatewayProxyResult> => {
  return {
    statusCode: 200,
    body: JSON.stringify({ status: 'ok' })
  };
};

export const echoHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    // Example of fetching a parameter from SSM
    const apiKeyParam = await ssm.send(
      new GetParameterCommand({
        Name: '/myapp/api-key',
        WithDecryption: true
      })
    );

    const body = event.body ? JSON.parse(event.body) : {};

    return {
      statusCode: 200,
      body: JSON.stringify({
        youSent: body,
        // Include API key in response for demo purposes only
        apiKeyExists: !!apiKeyParam.Parameter?.Value
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