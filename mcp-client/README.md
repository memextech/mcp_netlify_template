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

2. Configure the environment variables in the `.env` file:
   ```
   # The URL of the MCP server to connect to
   MCP_SERVER_URL=http://localhost:8888/mcp
   
   # The base URL for the API client (used by test_client.py)
   API_BASE=http://localhost:8001
   ```
   
   Replace these values with your actual URLs if they're different.

## Usage

### Managing Services

The following scripts are provided to help manage the MCP server and FastAPI client:

- **start.sh**: Starts both the Netlify MCP server and FastAPI client in the background
  ```bash
  ./start.sh
  ```

- **stop.sh**: Stops both services properly
  ```bash
  ./stop.sh
  ```

- **check_status.sh**: Checks the status of both services and displays logs
  ```bash
  ./check_status.sh
  ```

- **test_client.py**: Runs tests against the FastAPI client
  ```bash
  ./test_client.py
  ```

### Starting the Server Manually

If you prefer to start the FastAPI client manually:

```bash
uvicorn main:app --reload --port 8001
```

The API will be available at http://localhost:8001

### API Documentation

Interactive API documentation is available at http://localhost:8001/docs

### Troubleshooting

If you encounter issues:

1. Check if the ports are already in use (8001 for FastAPI, 8888 for Netlify)
2. Verify both services are running with `./check_status.sh`
3. Check the log files in the `.processes` directory
4. Ensure your `.env` file has the correct URLs
5. Try stopping and restarting both services with `./stop.sh` followed by `./start.sh`

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