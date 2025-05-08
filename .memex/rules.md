# MCP Server Template for Netlify

This template provides a barebones implementation of a Model Context Protocol (MCP) server designed to be deployed to Netlify. The MCP server exposes tools and resources that can be used by AI assistants through the open MCP standard.

## Project Structure

```
.
├── netlify/
│   └── functions/           # Serverless functions for Netlify
│       ├── mcp-server.js    # MCP implementation using the SDK (not used by default)
│       └── simple-mcp.js    # Simple MCP implementation without external dependencies
├── public/                  # Static assets served by Netlify
│   └── index.html           # Landing page with documentation
├── .gitignore               # Git ignore file
├── netlify.toml             # Netlify configuration
├── package.json             # Node.js dependencies
└── README.md                # Project documentation
```

## Core Components

### 1. Simple MCP Server Implementation (`netlify/functions/simple-mcp.js`)

This is a lightweight implementation of the Model Context Protocol without using the full MCP SDK. It supports:

- Server initialization (`mcp/init`)
- Tool listing (`mcp/listTools`) 
- Tool execution (`mcp/callTool`)
- Resource listing (`mcp/listResources`)
- Resource reading (`mcp/readResource`)

The server includes a sample tool (`run-analysis-report`) and a sample resource (`interpreting-reports`).

### 2. Configuration (`netlify.toml`)

Configures the Netlify deployment and sets up URL redirects to route `/mcp` to the serverless function.

### 3. Landing Page (`public/index.html`)

A simple documentation page explaining what the MCP server does and how to use it.

## Getting Started

### Development Prerequisites

- Node.js (v14 or later) 
- npm or yarn
- Netlify CLI (for local development and deployment)

### Local Development

1. Install dependencies:
   ```
   npm install
   ```

2. Start the development server:
   ```
   npm run dev
   ```
   
The MCP server will be available locally at `http://localhost:8888/mcp`

### Testing Your MCP Server

#### Using MCP Inspector

While the development server is running, you can test your MCP server using the MCP inspector:

```
npx @modelcontextprotocol/inspector npx mcp-remote@next http://localhost:8888/mcp
```

Then open `http://localhost:6274/` in your browser to interact with the MCP inspector.

#### Using curl

You can test the MCP server directly using curl commands:

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

#### Option 1: Using Netlify CLI

1. Install Netlify CLI globally (if not already installed):
   ```
   npm install -g netlify-cli
   ```

2. Login to Netlify:
   ```
   netlify login
   ```

3. Create a new site:
   ```
   netlify sites:create --name your-site-name
   ```

4. Deploy the site:
   ```
   netlify deploy --prod
   ```

#### Option 2: Using Netlify UI

1. Push your repository to GitHub, GitLab, or Bitbucket
2. Log in to the Netlify web interface
3. Click "New site from Git"
4. Connect your repository
5. Configure the build settings:
   - Build command: leave empty (no build required)
   - Publish directory: `public`
6. Click "Deploy site"

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

## Extending the Template

### Adding New Tools

To add a new tool, locate the `simple-mcp.js` file and add your tool to the appropriate sections:

1. Add your tool to the `mcp/listTools` response
2. Add a condition for your tool in the `mcp/callTool` handler

Example of adding a new tool:

```javascript
// In the mcp/listTools handler
tools: [
  // Existing tools...
  {
    name: "your-new-tool-name",
    description: "Description of what your tool does",
    schema: {
      type: "object",
      properties: {
        // Define your tool's parameters here
        param1: {
          type: "string",
          description: "Description of param1"
        }
      },
      required: ["param1"],
      additionalProperties: false
    }
  }
]

// In the mcp/callTool handler
if (name === "your-new-tool-name") {
  const param1 = args?.param1;
  
  // Your tool's logic here
  const result = doSomethingWith(param1);
  
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      result: {
        content: [
          {
            type: "text",
            text: JSON.stringify(result)
          }
        ]
      },
      id
    })
  };
}
```

### Adding New Resources

To add a new resource:

1. Add your resource to the `mcp/listResources` response
2. Add a condition for your resource in the `mcp/readResource` handler

Example:

```javascript
// In the mcp/listResources handler
resources: [
  // Existing resources...
  {
    name: "your-new-resource",
    uri: "docs://your-new-resource",
    metadata: { mimeType: "text/plain" }
  }
]

// In the mcp/readResource handler
if (uri === "docs://your-new-resource") {
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      result: {
        contents: [
          {
            uri: "docs://your-new-resource",
            text: "Content of your resource..."
          }
        ]
      },
      id
    })
  };
}
```

### Adding External API Integrations

To integrate with external APIs, update the tool implementation to make API calls:

1. Add necessary API client packages to `package.json`
2. Import and configure the client in your function
3. Make API calls within the tool handler
4. Return the processed results

Remember to handle authentication securely using Netlify environment variables.

## Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Netlify Functions Documentation](https://docs.netlify.com/functions/overview/)
- [Claude Desktop Documentation](https://claude.ai/docs)