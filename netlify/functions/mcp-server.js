// mcp-server.js - CommonJS format for Netlify serverless function
const { StreamableHTTPServerTransport } = require("@modelcontextprotocol/sdk").server.StreamableHTTPServerTransport;
const { toFetchResponse, toReqRes } = require("fetch-to-node");
const { z } = require("zod");
const { McpServer } = require("@modelcontextprotocol/sdk").server.McpServer;
const { JSONRPCError } = require("@modelcontextprotocol/sdk").types;

// Netlify serverless function handler which handles all inbound requests
exports.handler = async (event, context) => {
  const req = new Request(`https://${event.headers.host}${event.path}`, {
    method: event.httpMethod,
    headers: event.headers,
    body: event.body ? Buffer.from(event.body, 'base64').toString() : undefined
  });
  try {
    // for stateless MCP, we'll only use the POST requests that are sent
    // with event information for the init phase and resource/tool requests
    if (req.method === "POST") {
      // Convert the Request object into a Node.js Request object
      const { req: nodeReq, res: nodeRes } = toReqRes(req);
      const server = getServer();
      const transport = new StreamableHTTPServerTransport({
        sessionIdGenerator: undefined,
      });

      await server.connect(transport);
      
      let body;
      try {
        body = await req.json();
      } catch (e) {
        console.error("Error parsing JSON body:", e);
        return { 
          statusCode: 400, 
          body: JSON.stringify({error: "Invalid JSON body"}) 
        };
      }
      
      await transport.handleRequest(nodeReq, nodeRes, body);
      
      nodeRes.on("close", () => {
        console.log("Request closed");
        transport.close();
        server.close();
      });
      
      const response = toFetchResponse(nodeRes);
      
      // Convert the Response to Netlify function format
      const responseBody = await response.text();
      const headers = {};
      response.headers.forEach((value, key) => {
        headers[key] = value;
      });
      
      return {
        statusCode: response.status,
        headers: headers,
        body: responseBody
      };
    }

    return {
      statusCode: 405,
      body: "Method not allowed"
    };
  } catch (error) {
    console.error("MCP error:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        jsonrpc: "2.0",
        error: {
          code: -32603,
          message: "Internal server error",
        },
        id: '',
      })
    };
  }
};

function getServer() {
  // initialize our MCP Server instance that we will
  // attach all of our functionality and data.
  const server = new McpServer(
    {
      name: "basic-mcp-server",
      version: "1.0.0",
    },
    { capabilities: { logging: {} } }
  );

  // Add a simple tool for running an analysis report
  server.tool(
    "run-analysis-report",
    "Generates a sample data analysis report with random growth metrics.",
    {
      days: z.number().describe("Number of days to analyze").default(7),
    },
    async (
      { days },
    ) => {
      const random = Math.random() * 100;
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              lastNDays: days,
              data: Array.from({ length: days }, (_, i) => `Day ${i + 1} had ${random * days} growth.`),
            }),
          },
        ],
      };
    }
  );

  // Add a resource with information about interpreting reports
  server.resource(
    "interpreting-reports",
    "docs://interpreting-reports",
    { mimeType: "text/plain" },
    async () => {
      return {
        contents: [
          {
            uri: "docs://interpreting-reports",
            text: `Reports from this MCP include an array of text that informs the growth over a specified number of days. It's unstructured text but is consistent so parsing the information can be based on looking at a single line to understand where the data is.`,
          },
        ],
      };
    }
  );

  return server;
}

// We don't need to export a config object here since we're using redirects in netlify.toml