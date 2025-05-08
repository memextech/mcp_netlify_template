#!/usr/bin/env python3
"""
Simple script to test the MCP client API.
"""

import requests
import json
import sys
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Default to localhost if API_BASE not set
API_BASE = os.getenv("API_BASE", "http://localhost:8001")

def pretty_print(data):
    """Print JSON data in a readable format."""
    print(json.dumps(data, indent=2))

def test_server_info():
    """Test the server info endpoint."""
    print("Testing server info...")
    response = requests.get(f"{API_BASE}/server")
    pretty_print(response.json())
    print()

def test_list_tools():
    """Test the list tools endpoint."""
    print("Testing list tools...")
    response = requests.get(f"{API_BASE}/tools")
    pretty_print(response.json())
    print()

def test_call_tool():
    """Test calling a tool."""
    print("Testing call tool (run-analysis-report with 3 days)...")
    response = requests.post(
        f"{API_BASE}/tools/call",
        json={"name": "run-analysis-report", "args": {"days": 3}}
    )
    pretty_print(response.json())
    print()

def test_list_resources():
    """Test the list resources endpoint."""
    print("Testing list resources...")
    response = requests.get(f"{API_BASE}/resources")
    pretty_print(response.json())
    print()

def test_read_resource():
    """Test reading a resource."""
    print("Testing read resource (interpreting-reports)...")
    response = requests.post(
        f"{API_BASE}/resources/read",
        json={"uri": "docs://interpreting-reports"}
    )
    pretty_print(response.json())
    print()

def main():
    """Run all tests."""
    test_server_info()
    test_list_tools()
    test_call_tool()
    test_list_resources()
    test_read_resource()

if __name__ == "__main__":
    main()