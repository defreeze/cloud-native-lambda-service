import { APIGatewayProxyEvent } from 'aws-lambda';
import { healthHandler, echoHandler } from '../../src/index';

// Set test environment
process.env.NODE_ENV = 'test';

describe('Lambda Handlers', () => {
  describe('healthHandler', () => {
    it('should return status ok', async () => {
      const response = await healthHandler();
      expect(response.statusCode).toBe(200);
      expect(JSON.parse(response.body)).toEqual({ status: 'ok' });
    });
  });

  describe('echoHandler', () => {
    it('should echo back the request body', async () => {
      const event = {
        body: JSON.stringify({ test: 'data' })
      } as APIGatewayProxyEvent;

      const response = await echoHandler(event);
      expect(response.statusCode).toBe(200);
      expect(JSON.parse(response.body)).toHaveProperty('youSent');
    });
  });
});