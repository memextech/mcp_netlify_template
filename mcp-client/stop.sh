#!/bin/bash

# Create a process management directory
PROCESS_DIR="../.processes"

# Function to stop a service
stop_service() {
  local service_name=$1
  local pid_file="$PROCESS_DIR/$service_name.pid"
  
  if [ -f "$pid_file" ]; then
    local pid=$(cat "$pid_file")
    echo "Stopping $service_name (PID: $pid)..."
    
    if kill -0 $pid 2>/dev/null; then
      kill $pid
      sleep 1
      
      # Check if process is still running
      if kill -0 $pid 2>/dev/null; then
        echo "Process still running, sending SIGKILL..."
        kill -9 $pid 2>/dev/null
      fi
      
      echo "$service_name stopped successfully."
    else
      echo "$service_name is not running."
    fi
    
    rm -f "$pid_file"
  else
    echo "No PID file found for $service_name."
  fi
}

# Check if processes directory exists
if [ ! -d "$PROCESS_DIR" ]; then
  echo "Process directory not found. No servers are running."
  exit 0
fi

# Stop the FastAPI client
stop_service "fastapi"

# Stop the Netlify server
stop_service "netlify"

echo "All servers have been stopped."