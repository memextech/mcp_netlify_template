#!/bin/bash

# Create a process management directory
PROCESS_DIR="../.processes"
mkdir -p $PROCESS_DIR

# Check if servers are already running
if [ -f "$PROCESS_DIR/netlify.pid" ] && kill -0 $(cat $PROCESS_DIR/netlify.pid) 2>/dev/null; then
  echo "Netlify MCP server is already running with PID $(cat $PROCESS_DIR/netlify.pid)"
  NETLIFY_RUNNING=true
else
  NETLIFY_RUNNING=false
fi

if [ -f "$PROCESS_DIR/fastapi.pid" ] && kill -0 $(cat $PROCESS_DIR/fastapi.pid) 2>/dev/null; then
  echo "FastAPI client is already running with PID $(cat $PROCESS_DIR/fastapi.pid)"
  FASTAPI_RUNNING=true
else
  FASTAPI_RUNNING=false
fi

# Function to start the Netlify server
start_netlify_server() {
  # Activate virtual environment if it exists
  if [ -d "../.venv" ]; then
    echo "Activating virtual environment..."
    source ../.venv/bin/activate
  fi

  # Start the Netlify MCP server in the background with nohup to keep it running
  cd ..
  echo "Starting Netlify MCP server..."
  nohup npx netlify-cli dev > $PROCESS_DIR/netlify-dev.log 2>&1 &
  NETLIFY_PID=$!
  echo $NETLIFY_PID > $PROCESS_DIR/netlify.pid
  echo "Netlify MCP server started with PID $NETLIFY_PID"
  echo "Logs: $PROCESS_DIR/netlify-dev.log"

  # Wait for the server to start
  echo "Waiting for server to start (5 seconds)..."
  sleep 5
  
  # Verify the server is running
  if ! kill -0 $NETLIFY_PID 2>/dev/null; then
    echo "ERROR: Netlify server failed to start. Check logs at $PROCESS_DIR/netlify-dev.log"
    return 1
  fi
  
  # Check if server responds
  if ! curl -s "http://localhost:8888/mcp" > /dev/null; then
    echo "WARNING: Netlify server doesn't seem to be responding at http://localhost:8888/mcp"
    echo "This might be normal for the MCP server which only accepts POST requests."
  fi
  
  return 0
}

# Function to start the FastAPI client
start_fastapi_client() {
  # Activate virtual environment if it exists and not already activated
  if [ -d "../.venv" ] && [[ "$VIRTUAL_ENV" != *".venv"* ]]; then
    echo "Activating virtual environment..."
    source ../.venv/bin/activate
  fi

  # Start the FastAPI client in the background with nohup
  cd ../mcp-client
  echo "Starting MCP FastAPI client..."
  nohup python -m uvicorn main:app --reload --port 8001 > $PROCESS_DIR/fastapi.log 2>&1 &
  FASTAPI_PID=$!
  echo $FASTAPI_PID > $PROCESS_DIR/fastapi.pid
  echo "FastAPI client started with PID $FASTAPI_PID"
  echo "Logs: $PROCESS_DIR/fastapi.log"

  # Wait for API to start
  echo "Waiting for FastAPI to start (3 seconds)..."
  sleep 3
  
  # Verify the server is running
  if ! kill -0 $FASTAPI_PID 2>/dev/null; then
    echo "ERROR: FastAPI server failed to start. Check logs at $PROCESS_DIR/fastapi.log"
    return 1
  fi
  
  # Check if server responds
  if ! curl -s "http://localhost:8001/" > /dev/null; then
    echo "WARNING: FastAPI server doesn't seem to be responding at http://localhost:8001/"
  fi
  
  return 0
}

# Function to test the client
run_tests() {
  echo "Running test client..."
  python test_client.py
}

# Start servers if not already running
if [ "$NETLIFY_RUNNING" = false ]; then
  start_netlify_server || { echo "Failed to start Netlify server"; exit 1; }
fi

if [ "$FASTAPI_RUNNING" = false ]; then
  start_fastapi_client || { echo "Failed to start FastAPI client"; exit 1; }
fi

# Display service status and URLs
echo ""
echo "Services Status:"
echo "- Netlify MCP Server: Running at http://localhost:8888/mcp (PID: $(cat $PROCESS_DIR/netlify.pid))"
echo "- FastAPI Client: Running at http://localhost:8001 (PID: $(cat $PROCESS_DIR/fastapi.pid))"
echo ""
echo "Access Points:"
echo "- FastAPI UI: http://localhost:8001/docs"
echo "- API Base: http://localhost:8001"
echo ""
echo "Environment Variables:"
echo "- MCP_SERVER_URL=$MCP_SERVER_URL (defaults to http://localhost:8888/mcp if not set)"
echo ""
echo "Run Tests: ./test_client.py"
echo "Stop Servers: ./stop.sh"
echo ""

# Ask if user wants to run tests
read -p "Would you like to run the test client now? (y/n): " RESPONSE
if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
  run_tests
fi