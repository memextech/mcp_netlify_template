const { z } = require('zod');

// Simple MCP server implementation without the full SDK
exports.handler = async (event) => {
  // Only handle POST requests
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: 'Method Not Allowed'
    };
  }

  try {
    const body = JSON.parse(event.body);
    const { method, params, id } = body;

    // MCP initialization - provide server information and capabilities
    if (method === 'mcp/init') {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          jsonrpc: '2.0',
          result: {
            server: {
              name: 'basic-mcp-server',
              version: '1.0.0',
            },
            protocol: {
              version: '0.1',
              capabilities: {
                logging: {}
              }
            }
          },
          id
        })
      };
    }
    
    // List tools available
    if (method === 'mcp/listTools') {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          jsonrpc: '2.0',
          result: {
            tools: [
              {
                name: 'run-analysis-report',
                description: 'Generates a sample data analysis report with random growth metrics.',
                schema: {
                  type: 'object',
                  properties: {
                    days: {
                      type: 'number',
                      description: 'Number of days to analyze'
                    }
                  },
                  required: [],
                  additionalProperties: false
                }
              }
            ]
          },
          id
        })
      };
    }
    
    // Call a tool
    if (method === 'mcp/callTool') {
      const { name, args } = params;
      
      if (name === 'run-analysis-report') {
        // Default to 7 days if not specified
        const days = args?.days || 7;
        const random = Math.random() * 100;
        
        return {
          statusCode: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            jsonrpc: '2.0',
            result: {
              content: [
                {
                  type: 'text',
                  text: JSON.stringify({
                    lastNDays: days,
                    data: Array.from({ length: days }, (_, i) => `Day ${i + 1} had ${(random * days).toFixed(2)} growth.`),
                  })
                }
              ]
            },
            id
          })
        };
      }
      
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          jsonrpc: '2.0',
          error: {
            code: -32602,
            message: `Tool '${name}' not found`
          },
          id
        })
      };
    }
    
    // List resources
    if (method === 'mcp/listResources') {
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          jsonrpc: '2.0',
          result: {
            resources: [
              {
                name: 'interpreting-reports',
                uri: 'docs://interpreting-reports',
                metadata: { mimeType: 'text/plain' }
              }
            ]
          },
          id
        })
      };
    }
    
    // Read a resource
    if (method === 'mcp/readResource') {
      const { uri } = params;
      
      if (uri === 'docs://interpreting-reports') {
        return {
          statusCode: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            jsonrpc: '2.0',
            result: {
              contents: [
                {
                  uri: 'docs://interpreting-reports',
                  text: `Reports from this MCP include an array of text that informs the growth over a specified number of days. It's unstructured text but is consistent so parsing the information can be based on looking at a single line to understand where the data is.`
                }
              ]
            },
            id
          })
        };
      }
      
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          jsonrpc: '2.0',
          error: {
            code: -32602,
            message: `Resource '${uri}' not found`
          },
          id
        })
      };
    }
    
    // Method not found
    return {
      statusCode: 400,
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        error: {
          code: -32601,
          message: `Method '${method}' not found`
        },
        id
      })
    };
  } catch (error) {
    console.error('Error processing request:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        error: {
          code: -32603,
          message: 'Internal server error'
        },
        id: ''
      })
    };
  }
};