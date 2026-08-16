#!/usr/bin/env bash
# Deploy ChimeraOS Web OS to Google Cloud Run
# Usage: ./deploy-web-os.sh [--project PROJECT_ID] [--region REGION] [--service-name NAME]

set -euo pipefail

# Default values
PROJECT_ID=""
REGION="us-central1"
SERVICE_NAME="chimeraos-web-os"
IMAGE_NAME="chimeraos-web-os"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      PROJECT_ID="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --service-name)
      SERVICE_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate project ID
if [[ -z "${PROJECT_ID}" ]]; then
  PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
  if [[ -z "${PROJECT_ID}" ]]; then
    echo "Error: No GCP project specified. Use --project or set gcloud default project."
    exit 1
  fi
fi

echo "🚀 Deploying ChimeraOS Web OS to Cloud Run"
echo "   Project: ${PROJECT_ID}"
echo "   Region: ${REGION}"
echo "   Service: ${SERVICE_NAME}"

# Navigate to web-os directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_OS_DIR="${SCRIPT_DIR}/../web-os"

cd "${WEB_OS_DIR}"

# Build frontend
echo "📦 Building frontend..."
npm install
npm run build

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t "gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest" .

# Push to Container Registry
echo "☁️  Pushing to Google Container Registry..."
docker push "gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest"

# Deploy to Cloud Run
echo "🌐 Deploying to Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
  --image "gcr.io/${PROJECT_ID}/${IMAGE_NAME}:latest" \
  --region "${REGION}" \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production \
  --set-env-vars PORT=8080 \
  --set-env-vars TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}" \
  --set-env-vars OPENAI_API_KEY="${OPENAI_API_KEY:-}" \
  --set-env-vars OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}" \
  --set-env-vars FIREBASE_API_KEY="${FIREBASE_API_KEY:-}" \
  --set-env-vars FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-}" \
  --memory 512Mi \
  --cpu 1 \
  --concurrency 80 \
  --timeout 300 \
  --min-instances 0 \
  --max-instances 10

# Get service URL
SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" \
  --region "${REGION}" \
  --platform managed \
  --format 'value(status.url)')

echo ""
echo "✅ Deployment complete!"
echo "   Service URL: ${SERVICE_URL}"
echo ""
echo "📝 Next steps:"
echo "   1. Test the deployment: curl ${SERVICE_URL}/health"
echo "   2. Configure custom domain (optional): ./scripts/deploy-web-os-custom-domain.sh"
echo "   3. Monitor logs: gcloud run logs read ${SERVICE_NAME} --region ${REGION}"
