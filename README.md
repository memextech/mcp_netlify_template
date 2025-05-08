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

### Testing with MCP Inspector

While the development server is running, you can test your MCP server using the MCP inspector:

```
npx @modelcontextprotocol/inspector npx mcp-remote@next http://localhost:8888/mcp
```

Then open http://localhost:6274/ in your browser to interact with the MCP inspector.

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