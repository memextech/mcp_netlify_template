# Barebones MCP Server for Netlify

This is a minimal implementation of a Model Context Protocol (MCP) server designed to be deployed to Netlify. The MCP server exposes tools and resources that can be used by AI assistants through the Model Context Protocol.

This project also includes a FastAPI client that provides a REST API for interacting with the MCP server, making it easy to test and integrate with other applications.

## Features

### MCP Server
- Simple serverless MCP server implementation
- Deployed on Netlify
- Includes a basic "run analysis report" tool
- Provides a resource with documentation on interpreting reports

### MCP Client
- FastAPI REST API for interacting with the MCP server
- Interactive API documentation (Swagger UI)
- Easy testing and integration
- Python script for automated testing

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

## Using the MCP Client

The MCP client provides a REST API interface for interacting with the MCP server. It's built with FastAPI and offers a clean, modern API with automatic documentation.

### Starting the Client

```bash
cd mcp-client
pip install -r requirements.txt
uvicorn main:app --reload
```

This will start the FastAPI server at http://localhost:8000. You can access the API documentation at http://localhost:8000/docs.

### Starting Both Server and Client

For convenience, a startup script is provided that starts both the MCP server and the client:

```bash
cd mcp-client
./start.sh
```

### Testing the Client

You can test the client using the provided test script:

```bash
cd mcp-client
./test_client.py
```

This will run a series of tests against the API endpoints and display the results.

### API Endpoints

- `GET /server` - Get server information
- `GET /tools` - List available tools
- `POST /tools/call` - Call a tool
- `GET /resources` - List available resources
- `POST /resources/read` - Read a resource

For more details, refer to the [MCP Client README](./mcp-client/README.md).

## Extending

### Extending the MCP Server

You can extend this MCP server by adding more tools and resources to the `getServer` function in `netlify/functions/mcp-server.js`. Follow the existing examples and refer to the [Model Context Protocol documentation](https://modelcontextprotocol.io/) for more information.

### Extending the MCP Client

To add new endpoints to the MCP client, edit the `main.py` file in the `mcp-client` directory. The client is built with FastAPI, which makes it easy to add new routes and functionality.

## Learn More

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Netlify Functions Documentation](https://docs.netlify.com/functions/overview/)
- [Claude Desktop Documentation](https://claude.ai/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)