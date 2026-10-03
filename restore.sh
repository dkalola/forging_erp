#!/bin/bash

# Configuration
CONTAINER_NAME="frappe_docker-backend-1"
APP_NAME="forging_erp"
REPO_URL="https://github.com/dkalola/forging_erp.git"
SITE_NAME="frontend"  # <-- Change this to your ERPNext site name

echo "=========================================="
echo "Starting restore for custom app: $APP_NAME"
echo "=========================================="

# Step 1: Clone the repository inside the Docker container apps directory
echo "-> Cloning repository into Docker container..."
docker exec -it "$CONTAINER_NAME" bash -c "
    cd /home/frappe/frappe-bench/apps
    if [ -d '$APP_NAME' ]; then
        echo 'App directory already exists. Pulling latest changes...'
        cd '$APP_NAME' && git pull origin main
    else
        git clone '$REPO_URL'
    fi
"

# Step 2: Install the app onto the ERPNext site
echo "-> Installing app on site: $SITE_NAME..."
docker exec -it "$CONTAINER_NAME" bench --site "$SITE_NAME" install-app "$APP_NAME"

# Step 3: Run database migrations
echo "-> Running database migrations..."
docker exec -it "$CONTAINER_NAME" bench --site "$SITE_NAME" migrate

# Step 4: Build assets
echo "-> Building frontend assets..."
docker exec -it "$CONTAINER_NAME" bench build

# Step 5: Restart Docker containers to apply everything cleanly
echo "-> Restarting Docker containers..."
docker compose down
docker compose up -d

echo "=========================================="
echo "✅ Custom app restored and installed successfully!"
echo "=========================================="