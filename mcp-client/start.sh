#!/bin/bash

# Start the Netlify MCP server in the background
cd ..
echo "Starting Netlify MCP server..."
npx netlify-cli dev > netlify-dev.log 2>&1 &
NETLIFY_PID=$!
echo "Netlify MCP server started with PID $NETLIFY_PID"

# Wait for the server to start
echo "Waiting for server to start (5 seconds)..."
sleep 5

# Start the FastAPI client in the foreground
cd mcp-client
echo "Starting MCP FastAPI client..."
uvicorn main:app --reload

# Cleanup function
function cleanup {
  echo "Stopping Netlify MCP server..."
  kill $NETLIFY_PID
  echo "Done"
}

# Register the cleanup function on script exit
trap cleanup EXIT