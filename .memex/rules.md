# MCP Server Template for Netlify

This template provides a barebones implementation of a Model Context Protocol (MCP) server designed to be deployed to Netlify. The MCP server exposes tools and resources that can be used by AI assistants through the open MCP standard.

Additionally, this template includes a FastAPI client that provides a REST API for interacting with the MCP server, making it easy to test and integrate with other applications.

## Project Structure

```
.
├── netlify/
│   └── functions/           # Serverless functions for Netlify
│       ├── mcp-server.js    # MCP implementation using the SDK (not used by default)
│       └── simple-mcp.js    # Simple MCP implementation without external dependencies
├── public/                  # Static assets served by Netlify
│   └── index.html           # Landing page with documentation
├── mcp-client/              # FastAPI client for interacting with the MCP server
│   ├── main.py              # FastAPI application
│   ├── test_client.py       # Script to test the client
│   ├── start.sh             # Script to start both server and client
│   ├── requirements.txt     # Python dependencies
│   └── README.md            # Client-specific documentation
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

### 4. FastAPI Client (`mcp-client/main.py`)

A REST API client built with FastAPI that provides a web interface for interacting with the MCP server. It includes endpoints for:

- Getting server information
- Listing available tools
- Calling tools with parameters
- Listing available resources
- Reading resources

The client includes comprehensive API documentation using Swagger UI.

## Getting Started

### Development Prerequisites

- Node.js (v14 or later) 
- npm or yarn
- Netlify CLI (for local development and deployment)

### Local Development

#### MCP Server

1. Install dependencies:
   ```
   npm install
   ```

2. Start the development server:
   ```
   npm run dev
   ```
   
The MCP server will be available locally at `http://localhost:8888/mcp`

#### MCP Client

1. Navigate to the mcp-client directory:
   ```
   cd mcp-client
   ```

2. Install Python dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Start the FastAPI server:
   ```
   uvicorn main:app --reload
   ```

The FastAPI client will be available at `http://localhost:8001` with API documentation at `http://localhost:8001/docs`

#### Managing the MCP Server and FastAPI Client

The template includes several scripts to manage both the MCP server and FastAPI client:

**Starting Services**:
```bash
cd mcp-client
./start.sh
```
This script starts both services in the background using `nohup` to ensure they keep running even if your terminal session ends. PID files are stored in the `.processes` directory for management.

**Checking Status**:
```bash
cd mcp-client
./check_status.sh
```
Verifies if both services are running, checks their responsiveness, and shows the latest log entries.

**Stopping Services**:
```bash
cd mcp-client
./stop.sh
```
Gracefully stops both services and cleans up the PID files.

**Running Tests**:
```bash
cd mcp-client
./test_client.py
```
Executes a series of tests against the FastAPI client to verify everything is working.

**Environment Variables**:

The FastAPI client uses the following environment variables (configured in `.env`):
- `MCP_SERVER_URL`: The URL of the MCP server (default: http://localhost:8888/mcp)
- `API_BASE`: The base URL for the FastAPI client (default: http://localhost:8001)

**Troubleshooting**:

If you encounter issues with the services:
1. Check if ports 8001 (FastAPI) and 8888 (Netlify) are already in use
2. Examine the log files in `.processes/` directory
3. Ensure you have the correct environment variables set
4. Try stopping and restarting both services
5. For specific service errors, check the respective logs:
   - Netlify MCP Server: `.processes/netlify-dev.log`
   - FastAPI Client: `.processes/fastapi.log`

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

#### Option 1: Non-interactive Deployment

This option is best if you already have Netlify configured on your machine:

1. Install Netlify CLI globally (if not already installed):
   ```bash
   npm install -g netlify-cli
   ```

2. Login to Netlify (if not already logged in):
   ```bash
   netlify login
   ```

3. Find your account slug:
   ```bash
   netlify status
   # Look for "Teams:" in the output
   ```

4. Create a new site non-interactively:
   ```bash
   netlify sites:create --account-slug YOUR-ACCOUNT-SLUG --name your-mcp-server-name
   ```

5. Deploy the site:
   ```bash
   netlify deploy --prod
   ```

#### Option 2: Interactive Deployment

This option is recommended for first-time Netlify users or if you need to authenticate with Netlify:

1. Install Netlify CLI globally (if not already installed):
   ```bash
   npm install -g netlify-cli
   ```

2. Open a new terminal window to handle the interactive authentication:

   **macOS**:
   ```bash
   osascript -e 'tell application "Terminal" to do script "cd \"$(pwd)\" && netlify login"'
   ```

   **Windows**:
   ```bash
   start powershell -NoExit -Command "cd \"$(pwd)\"; netlify login"
   ```

   **Linux (Ubuntu)**:
   ```bash
   gnome-terminal -- bash -c "cd \"$(pwd)\" && netlify login; exec bash"
   ```

3. After authenticating, in the new terminal window, create a site interactively:
   ```bash
   netlify sites:create
   ```

4. Return to your original terminal and deploy the site:
   ```bash
   netlify deploy --prod
   ```

After deployment with either method, your MCP server will be available at `https://your-site-name.netlify.app/mcp`

### Using the FastAPI Client

The template includes a FastAPI client that provides a user-friendly REST API interface for interacting with the MCP server:

1. **Starting both the MCP server and FastAPI client**:
   ```bash
   cd mcp-client
   ./start.sh
   ```
   This script starts both the Netlify MCP server and the FastAPI client, then runs a quick test to verify everything is working.

2. **Accessing the API documentation**:
   Open `http://localhost:8001/docs` in your browser to use the interactive Swagger UI documentation.

3. **API Endpoints**:
   - `GET /server` - Get information about the MCP server
   - `GET /tools` - List available tools
   - `POST /tools/call` - Call a specific tool with parameters
   - `GET /resources` - List available resources
   - `POST /resources/read` - Read a specific resource

4. **Example: Calling a tool via curl**:
   ```bash
   curl -X POST http://localhost:8001/tools/call \
     -H "Content-Type: application/json" \
     -d '{"name":"run-analysis-report","args":{"days":5}}'
   ```

5. **Example: Reading a resource via curl**:
   ```bash
   curl -X POST http://localhost:8001/resources/read \
     -H "Content-Type: application/json" \
     -d '{"uri":"docs://interpreting-reports"}'
   ```

The FastAPI client makes it easy to test and integrate the MCP server with other applications without needing to implement the MCP protocol directly.

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