#!/usr/bin/env bash
# Map custom domain to ChimeraOS Web OS on Cloud Run
# Usage: ./deploy-web-os-custom-domain.sh --domain chimeraos.ai.studio

set -euo pipefail

# Default values
DOMAIN=""
REGION="us-central1"
SERVICE_NAME="chimeraos-web-os"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --domain)
      DOMAIN="$2"
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

# Validate domain
if [[ -z "${DOMAIN}" ]]; then
  echo "Error: --domain is required"
  echo "Usage: $0 --domain chimeraos.ai.studio"
  exit 1
fi

echo "🌐 Mapping custom domain to Cloud Run service"
echo "   Domain: ${DOMAIN}"
echo "   Service: ${SERVICE_NAME}"
echo "   Region: ${REGION}"

# Create domain mapping
echo "📝 Creating domain mapping..."
gcloud run domain-mappings create \
  --service "${SERVICE_NAME}" \
  --domain "${DOMAIN}" \
  --region "${REGION}" \
  --project "$(gcloud config get-value project)"

echo ""
echo "✅ Domain mapping created!"
echo ""
echo "📝 DNS Configuration Required:"
echo ""
echo "   Add the following DNS records in your domain registrar:"
echo ""
echo "   Type: A"
echo "   Name: @ (or leave blank for root domain)"
echo "   Value: 64.233.177.121"
echo "   TTL: 300"
echo ""
echo "   Type: CNAME (for www subdomain)"
echo "   Name: www"
echo "   Value: ghs.googlehosted.com"
echo "   TTL: 300"
echo ""
echo "   Or use Google Domains and run:"
echo "   gcloud run domain-mappings describe ${DOMAIN} --region ${REGION}"
echo ""
echo "⏳ DNS propagation may take up to 24 hours."
echo ""
echo "🔍 Check status:"
echo "   gcloud run domain-mappings describe ${DOMAIN} --region ${REGION}"
