#!/bin/bash

# Flutter Environment Switcher Script
# This script helps you run Flutter with different API environments

echo "🚀 Flutter Environment Switcher"
echo "================================"

# Function to show current environment
show_current_env() {
    echo "📍 Current .env configuration:"
    echo "   API_ENVIRONMENT=$(grep API_ENVIRONMENT .env | cut -d'=' -f2)"
    echo "   API_BASE_URL=$(grep API_BASE_URL .env | cut -d'=' -f2)"
    echo ""
}

# Function to update environment
update_env() {
    local env=$1
    local url=$2
    
    echo "🔧 Updating environment to: $env"
    
    # Update API_ENVIRONMENT
    if grep -q "API_ENVIRONMENT=" .env; then
        sed -i '' "s/API_ENVIRONMENT=.*/API_ENVIRONMENT=$env/" .env
    else
        echo "API_ENVIRONMENT=$env" >> .env
    fi
    
    # Update API_BASE_URL if provided
    if [ ! -z "$url" ]; then
        if grep -q "API_BASE_URL=" .env; then
            sed -i '' "s|API_BASE_URL=.*|API_BASE_URL=$url|" .env
        else
            echo "API_BASE_URL=$url" >> .env
        fi
    fi
    
    echo "✅ Environment updated!"
    echo ""
}

# Function to run Flutter
run_flutter() {
    echo "🚀 Starting Flutter app..."
    echo "   Environment: $(grep API_ENVIRONMENT .env | cut -d'=' -f2)"
    echo "   Base URL: $(grep API_BASE_URL .env | cut -d'=' -f2)"
    echo ""
    
    flutter clean
    flutter pub get
    flutter run
}

# Show usage
show_usage() {
    echo "Usage: $0 [environment] [optional_url]"
    echo ""
    echo "Environments:"
    echo "  dev | development    - Development environment"
    echo "  prod | production    - Production environment"
    echo "  local                - Local development"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run with current environment"
    echo "  $0 dev                       # Switch to development and run"
    echo "  $0 production                # Switch to production and run"
    echo "  $0 local http://localhost:8080  # Switch to local with custom URL"
    echo ""
}

# Main script logic
case $1 in
    "dev"|"development")
        update_env "development" "https://dev-solar-projects-api.azurewebsites.net"
        run_flutter
        ;;
    "prod"|"production")
        update_env "production" "https://solar-projects-api.azurewebsites.net"
        run_flutter
        ;;
    "local")
        local_url=${2:-"http://localhost:8080"}
        update_env "local" "$local_url"
        run_flutter
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    "")
        show_current_env
        run_flutter
        ;;
    *)
        echo "❌ Unknown environment: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
