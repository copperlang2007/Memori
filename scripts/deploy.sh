#!/bin/bash
# Memori Deployment Helper Script
# This script helps with common deployment tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored message
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_info "Docker is installed: $(docker --version)"
}

# Check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    print_info "Docker Compose is installed"
}

# Setup environment file
setup_env() {
    if [ ! -f .env ]; then
        print_warn ".env file not found"
        if [ -f .env.example ]; then
            print_info "Copying .env.example to .env"
            cp .env.example .env
            print_warn "Please edit .env and add your API keys before deploying"
            exit 0
        else
            print_error ".env.example not found"
            exit 1
        fi
    else
        print_info ".env file exists"
    fi
}

# Build Docker images
build_images() {
    print_info "Building Docker images..."
    docker-compose build
    print_info "Build complete!"
}

# Start services
start_services() {
    print_info "Starting services..."
    docker-compose up -d
    print_info "Services started!"
    echo ""
    print_info "Access your services at:"
    echo "  - Documentation: http://localhost:8000"
    echo "  - Personal Diary: http://localhost:8501"
    echo "  - Researcher Agent: http://localhost:8502"
    echo "  - Travel Planner: http://localhost:8503"
    echo "  - Job Search: http://localhost:8504"
    echo "  - Product Launch: http://localhost:8505"
}

# Stop services
stop_services() {
    print_info "Stopping services..."
    docker-compose down
    print_info "Services stopped!"
}

# View logs
view_logs() {
    service=$1
    if [ -z "$service" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$service"
    fi
}

# Check service health
check_health() {
    print_info "Checking service health..."
    docker-compose ps
}

# Clean up
cleanup() {
    print_warn "This will remove all containers, volumes, and images. Continue? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_info "Cleaning up..."
        docker-compose down -v --rmi all
        print_info "Cleanup complete!"
    else
        print_info "Cleanup cancelled"
    fi
}

# Deploy documentation to GitHub Pages
deploy_docs() {
    print_info "Building documentation..."
    if command -v mkdocs &> /dev/null; then
        mkdocs build
        print_info "Documentation built successfully!"
        print_info "Deploy to GitHub Pages by pushing to main branch"
    else
        print_error "mkdocs not installed. Install with: pip install mkdocs mkdocs-material"
        exit 1
    fi
}

# Show usage
usage() {
    cat << EOF
Memori Deployment Helper Script

Usage: $0 [command]

Commands:
    setup       - Setup environment file from .env.example
    build       - Build Docker images
    start       - Start all services
    stop        - Stop all services
    restart     - Restart all services
    logs [svc]  - View logs (optionally for specific service)
    health      - Check service health
    cleanup     - Remove all containers, volumes, and images
    docs        - Build and deploy documentation
    help        - Show this help message

Examples:
    $0 setup          # Create .env file
    $0 build          # Build images
    $0 start          # Start all services
    $0 logs docs      # View documentation service logs
    $0 stop           # Stop all services

EOF
}

# Main script
main() {
    command=${1:-help}

    case $command in
        setup)
            setup_env
            ;;
        build)
            check_docker
            check_docker_compose
            setup_env
            build_images
            ;;
        start)
            check_docker
            check_docker_compose
            setup_env
            start_services
            ;;
        stop)
            check_docker
            check_docker_compose
            stop_services
            ;;
        restart)
            check_docker
            check_docker_compose
            stop_services
            start_services
            ;;
        logs)
            check_docker
            check_docker_compose
            view_logs "$2"
            ;;
        health)
            check_docker
            check_docker_compose
            check_health
            ;;
        cleanup)
            check_docker
            check_docker_compose
            cleanup
            ;;
        docs)
            deploy_docs
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
