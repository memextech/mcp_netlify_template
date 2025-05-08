#!/bin/bash

# Create a process management directory
PROCESS_DIR="../.processes"

# Check if processes directory exists
if [ ! -d "$PROCESS_DIR" ]; then
  echo "Process directory not found. No servers are running."
  exit 0
fi

# Function to check a service
check_service() {
  local service_name=$1
  local url=$2
  local pid_file="$PROCESS_DIR/$service_name.pid"
  local log_file="$PROCESS_DIR/$service_name-dev.log"
  
  if [ "$service_name" = "fastapi" ]; then
    log_file="$PROCESS_DIR/$service_name.log"
  fi
  
  echo "====== $service_name Status ======"
  
  if [ -f "$pid_file" ]; then
    local pid=$(cat "$pid_file")
    echo "PID: $pid"
    
    if kill -0 $pid 2>/dev/null; then
      echo "Status: Running"
      echo "URL: $url"
      
      # Try to get a response
      local status_code=""
      if [ "$service_name" = "netlify" ]; then
        # For MCP server, just check if port is open
        if nc -z localhost 8888 2>/dev/null; then
          echo "Port Check: Port 8888 is open"
        else
          echo "Port Check: Port 8888 is not responding"
        fi
      else
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        echo "Response: HTTP $status_code"
      fi
    else
      echo "Status: Process not running (stale PID file)"
    fi
  else
    echo "Status: Not running (no PID file)"
  fi
  
  echo "Log file: $log_file"
  
  if [ -f "$log_file" ]; then
    echo "Last 5 log lines:"
    tail -5 "$log_file"
  else
    echo "No log file found."
  fi
  
  echo ""
}

# Check each service
check_service "netlify" "http://localhost:8888/mcp"
check_service "fastapi" "http://localhost:8001"

echo "To restart services: ./start.sh"
echo "To stop services: ./stop.sh"