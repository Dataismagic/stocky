#!/bin/bash

# Render deployment script
echo "🚀 Starting Render deployment for Stocky Backend..."

# Set deployment environment
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

echo "✅ Environment configured for Render deployment"
echo "📦 Building Docker container..."

# The actual build will be handled by Render's Docker environment
# This script is mainly for documentation and local testing

echo "🔧 Environment Variables Required:"
echo "  - DATABASE_URL"
echo "  - DB_USERNAME" 
echo "  - DB_PASSWORD"
echo "  - JWT_SECRET"
echo "  - JWT_EXPIRATION_MS"
echo "  - SPRING_PROFILES_ACTIVE=prod"
echo "  - PORT=8080"
echo "  - CORS_ORIGINS"

echo "✅ Render deployment initiated. Check Render dashboard for progress."
