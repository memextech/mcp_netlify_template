#!/bin/bash

# Activate virtual environment if it exists
if [ -d "../.venv" ]; then
  echo "Activating virtual environment..."
  source ../.venv/bin/activate
fi

# Start the Netlify MCP server in the background
cd ..
echo "Starting Netlify MCP server..."
npx netlify-cli dev > netlify-dev.log 2>&1 &
NETLIFY_PID=$!
echo "Netlify MCP server started with PID $NETLIFY_PID"

# Wait for the server to start
echo "Waiting for server to start (5 seconds)..."
sleep 5

# Start the FastAPI client in the background
cd mcp-client
echo "Starting MCP FastAPI client..."
python -m uvicorn main:app --reload --port 8001 > fastapi.log 2>&1 &
FASTAPI_PID=$!
echo "FastAPI client started with PID $FASTAPI_PID"

# Wait for API to start
echo "Waiting for FastAPI to start (3 seconds)..."
sleep 3

# Run the test client
echo "Running test client..."
python test_client.py

# Keep the script running until Ctrl+C
echo ""
echo "Both servers are running. Press Ctrl+C to stop."
echo "FastAPI UI: http://localhost:8001/docs"
echo "MCP Server: http://localhost:8888/mcp"

# Cleanup function
function cleanup {
  echo "Stopping servers..."
  kill $NETLIFY_PID $FASTAPI_PID
  echo "Done"
}

# Register the cleanup function on script exit
trap cleanup EXIT

# Wait for Ctrl+C
wait