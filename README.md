# Barebones MCP Server for Netlify

This is a minimal implementation of a Model Context Protocol (MCP) server designed to be deployed to Netlify. The MCP server exposes tools and resources that can be used by AI assistants through the Model Context Protocol.

## Features

- Simple serverless MCP server implementation
- Deployed on Netlify
- Includes a basic "run analysis report" tool
- Provides a resource with documentation on interpreting reports

## Getting Started

### Local Development

1. Clone this repository
2. Install dependencies:
   ```
   npm install
   ```
3. Start the development server:
   ```
   npm run dev
   ```
   
The MCP server will be available locally at http://localhost:8888/mcp

### Testing Your MCP Server

You can test your MCP server using either the MCP Inspector or directly with curl commands.

#### Using MCP Inspector

While the development server is running, you can test your MCP server using the MCP inspector:

```
npx @modelcontextprotocol/inspector npx mcp-remote@next http://localhost:8888/mcp
```

After deployment, you can test your deployed version:

```
npx @modelcontextprotocol/inspector npx mcp-remote@next https://your-site-name.netlify.app/mcp
```

Then open http://localhost:6274/ in your browser to interact with the MCP inspector.

#### Using curl

You can also test the MCP server directly using curl commands:

1. Initialize the MCP server:
   ```
   curl -X POST http://localhost:8888/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"mcp/init","params":{},"id":"1"}'
   ```

2. List available tools:
   ```
   curl -X POST http://localhost:8888/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"mcp/listTools","params":{},"id":"2"}'
   ```

3. Call a tool:
   ```
   curl -X POST http://localhost:8888/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"mcp/callTool","params":{"name":"run-analysis-report","args":{"days":5}},"id":"3"}'
   ```

4. List available resources:
   ```
   curl -X POST http://localhost:8888/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"mcp/listResources","params":{},"id":"4"}'
   ```

5. Read a resource:
   ```
   curl -X POST http://localhost:8888/mcp \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"mcp/readResource","params":{"uri":"docs://interpreting-reports"},"id":"5"}'
   ```

## Deployment

### Deploying to Netlify

1. Push this repository to GitHub
2. Connect your repository to Netlify
3. Configure the build settings:
   - Build command: leave empty (no build required)
   - Publish directory: `public`
   
After deployment, your MCP server will be available at `https://your-site-name.netlify.app/mcp`

### Using with Claude Desktop

To use this MCP server with Claude Desktop:

1. Go to Claude Desktop settings
2. Enable the MCP Server configuration
3. Edit the configuration file:
   ```json
   {
     "mcpServers": {
       "my-mcp": {
         "command": "npx",
         "args": [
           "mcp-remote@next",
           "https://your-site-name.netlify.app/mcp"
         ]
       }
     }
   }
   ```
4. Restart Claude Desktop

## Extending

You can extend this MCP server by adding more tools and resources to the `getServer` function in `netlify/functions/mcp-server.js`. Follow the existing examples and refer to the [Model Context Protocol documentation](https://modelcontextprotocol.io/) for more information.

## Learn More

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Netlify Functions Documentation](https://docs.netlify.com/functions/overview/)
- [Claude Desktop Documentation](https://claude.ai/docs)