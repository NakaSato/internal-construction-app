#!/bin/bash

# Production System Status Checker
# This script checks the health and availability of production APIs

echo "🔍 Solar Projects API - Production Status Check"
echo "=============================================="
echo ""

# Production API URL
PROD_API="https://solar-projects-api.azurewebsites.net"
DEV_API="https://dev-solar-projects-api.azurewebsites.net"

# Function to check API endpoint
check_endpoint() {
    local url=$1
    local name=$2
    local endpoint=$3
    
    echo "🌐 Checking $name: $url$endpoint"
    
    # Check if the endpoint is reachable
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$url$endpoint" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        case $response in
            200|201|204)
                echo "   ✅ Status: $response - OK"
                ;;
            400|401|403|404)
                echo "   ⚠️  Status: $response - Client Error (but server is reachable)"
                ;;
            500|502|503|504)
                echo "   ❌ Status: $response - Server Error"
                ;;
            000)
                echo "   ❌ Status: Connection Failed - DNS/Network Issue"
                ;;
            *)
                echo "   ⚠️  Status: $response - Unknown Response"
                ;;
        esac
    else
        echo "   ❌ Status: Connection Failed - Host unreachable"
    fi
    echo ""
}

# Function to check DNS resolution
check_dns() {
    local hostname=$1
    local name=$2
    
    echo "🔍 DNS Resolution Check for $name"
    
    # Extract hostname from URL
    host=$(echo $hostname | sed 's|https\?://||' | cut -d'/' -f1)
    
    if nslookup $host > /dev/null 2>&1; then
        echo "   ✅ DNS Resolution: OK"
        ip=$(nslookup $host | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
        echo "   📍 IP Address: $ip"
    else
        echo "   ❌ DNS Resolution: FAILED"
    fi
    echo ""
}

# Function to check network connectivity
check_connectivity() {
    echo "🌐 Network Connectivity Check"
    
    # Check internet connectivity
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "   ✅ Internet connectivity: OK"
    else
        echo "   ❌ Internet connectivity: FAILED"
    fi
    
    # Check Azure connectivity
    if ping -c 1 azure.microsoft.com > /dev/null 2>&1; then
        echo "   ✅ Azure connectivity: OK"
    else
        echo "   ❌ Azure connectivity: FAILED"
    fi
    echo ""
}

# Main status check
echo "⏰ Check started at: $(date)"
echo ""

# Check network connectivity first
check_connectivity

# Check DNS resolution
check_dns "$PROD_API" "Production API"
check_dns "$DEV_API" "Development API"

# Check API endpoints
echo "🔗 API Endpoint Health Checks"
echo "============================="

# Production API endpoints
check_endpoint "$PROD_API" "Production API" "/"
check_endpoint "$PROD_API" "Production Auth" "/api/v1/auth/login"
check_endpoint "$PROD_API" "Production Health" "/health"
check_endpoint "$PROD_API" "Production Status" "/status"

# Development API endpoints (for comparison)
check_endpoint "$DEV_API" "Development API" "/"
check_endpoint "$DEV_API" "Development Auth" "/api/v1/auth/login"

# Summary
echo "📊 Status Summary"
echo "================="
echo "⏰ Check completed at: $(date)"
echo ""
echo "📋 Next Steps:"
echo "   1. If DNS resolution fails, check domain configuration"
echo "   2. If connection fails, verify Azure service status"
echo "   3. If 4xx/5xx errors, check API deployment and configuration"
echo "   4. For local testing, use: ./run_with_env.sh local"
echo ""
