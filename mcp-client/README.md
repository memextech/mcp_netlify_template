# MCP FastAPI Client

This is a FastAPI client for interacting with Model Context Protocol (MCP) servers. It provides a REST API interface to test and interact with MCP servers.

## Features

- Server information retrieval
- List available tools
- Call tools with parameters
- List available resources
- Read resources

## Prerequisites

- Python 3.7+
- pip

## Installation

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure the MCP server URL in the `.env` file:
   ```
   MCP_SERVER_URL=http://localhost:8888/mcp
   ```
   
   Replace with your MCP server URL if it's different.

## Usage

### Starting the Server

```bash
uvicorn main:app --reload --port 8001
```

The API will be available at http://localhost:8001

### API Documentation

Interactive API documentation is available at http://localhost:8001/docs

### API Endpoints

#### Server Information

```
GET /server
```

Returns information about the MCP server.

#### List Tools

```
GET /tools
```

Returns a list of available tools on the MCP server.

#### Call Tool

```
POST /tools/call
```

Calls a specific tool with the provided arguments.

Example request body:
```json
{
  "name": "run-analysis-report",
  "args": {
    "days": 5
  }
}
```

#### List Resources

```
GET /resources
```

Returns a list of available resources on the MCP server.

#### Read Resource

```
POST /resources/read
```

Reads a specific resource.

Example request body:
```json
{
  "uri": "docs://interpreting-reports"
}
```

## Using with Different MCP Servers

To use the client with a different MCP server, update the `MCP_SERVER_URL` in the `.env` file or set the environment variable before starting the server:

```bash
export MCP_SERVER_URL=https://your-mcp-server-url/mcp
uvicorn main:app --reload
```