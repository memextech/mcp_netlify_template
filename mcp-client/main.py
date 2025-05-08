from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import os
from typing import Dict, Any, List, Optional
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get MCP server URL from environment variables
MCP_SERVER_URL = os.getenv("MCP_SERVER_URL", "http://localhost:8888/mcp")

app = FastAPI(
    title="MCP Client API",
    description="A FastAPI client for interacting with Model Context Protocol (MCP) servers",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define models for request and response
class MCPServerInfo(BaseModel):
    name: str
    version: str

class MCPProtocolInfo(BaseModel):
    version: str
    capabilities: Dict[str, Any]

class MCPInitResponse(BaseModel):
    server: MCPServerInfo
    protocol: MCPProtocolInfo

class ToolRequest(BaseModel):
    name: str
    args: Dict[str, Any] = {}

class ToolContentItem(BaseModel):
    type: str
    text: str

class ToolResponse(BaseModel):
    content: List[ToolContentItem]

class ResourceRequest(BaseModel):
    uri: str

class ResourceContentItem(BaseModel):
    uri: str
    text: str

class ResourceResponse(BaseModel):
    contents: List[ResourceContentItem]

class ToolInfo(BaseModel):
    name: str
    description: str
    schema: Dict[str, Any]

class ToolsResponse(BaseModel):
    tools: List[ToolInfo]

class ResourceInfo(BaseModel):
    name: str
    uri: str
    metadata: Dict[str, str]

class ResourcesResponse(BaseModel):
    resources: List[ResourceInfo]

# Helper function to make MCP requests
async def call_mcp_server(method: str, params: Dict[str, Any] = None) -> Dict[str, Any]:
    if params is None:
        params = {}
    
    payload = {
        "jsonrpc": "2.0",
        "method": method,
        "params": params,
        "id": "1"
    }
    
    try:
        response = requests.post(MCP_SERVER_URL, json=payload)
        response.raise_for_status()
        result = response.json()
        
        if "error" in result:
            raise HTTPException(status_code=400, detail=result["error"]["message"])
        
        return result.get("result", {})
    except requests.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Failed to communicate with MCP server: {str(e)}")

# Define routes
@app.get("/", tags=["Info"])
async def root():
    return {
        "name": "MCP Client API",
        "description": "A FastAPI client for interacting with Model Context Protocol (MCP) servers",
        "mcp_server": MCP_SERVER_URL,
    }

@app.get("/server", tags=["Info"], response_model=MCPInitResponse)
async def get_server_info():
    """
    Initialize the MCP server and return server information
    """
    return await call_mcp_server("mcp/init")

@app.get("/tools", tags=["Tools"], response_model=ToolsResponse)
async def list_tools():
    """
    List all available tools on the MCP server
    """
    return await call_mcp_server("mcp/listTools")

@app.post("/tools/call", tags=["Tools"], response_model=ToolResponse)
async def call_tool(request: ToolRequest):
    """
    Call a specific tool on the MCP server with the provided arguments
    """
    return await call_mcp_server("mcp/callTool", {
        "name": request.name,
        "args": request.args
    })

@app.get("/resources", tags=["Resources"], response_model=ResourcesResponse)
async def list_resources():
    """
    List all available resources on the MCP server
    """
    return await call_mcp_server("mcp/listResources")

@app.post("/resources/read", tags=["Resources"], response_model=ResourceResponse)
async def read_resource(request: ResourceRequest):
    """
    Read a specific resource from the MCP server
    """
    return await call_mcp_server("mcp/readResource", {
        "uri": request.uri
    })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)