#!/usr/bin/env bash
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────
R2_BUCKET="pedroalcocer-photos"
R2_BASE_URL="https://photos.pedroalcocer.com"
PHOTOS_TS="src/data/photos.ts"
# ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage: $(basename "$0") <image> <alt text>

Publishes a photo to the site:
  1. Reads image dimensions
  2. Uploads to Cloudflare R2
  3. Adds entry to $PHOTOS_TS

Examples:
  $(basename "$0") ~/photos/street.jpg "Street scene, Chicago"
  $(basename "$0") scan-024.tiff "Harbor at dusk"

Supported formats: jpg, jpeg, png, webp, tiff, avif
EOF
  exit 1
}

# ── Arg parsing ───────────────────────────────────────────────────────
[[ $# -lt 2 ]] && usage

IMAGE="$1"
shift
ALT="$*"

if [[ ! -f "$IMAGE" ]]; then
  echo "Error: file not found: $IMAGE" >&2
  exit 1
fi

# ── Check dependencies ────────────────────────────────────────────────
if ! command -v wrangler &>/dev/null; then
  echo "Error: wrangler not found. Install with: npm install -g wrangler" >&2
  exit 1
fi

if ! command -v sips &>/dev/null; then
  echo "Error: sips not found (macOS built-in)" >&2
  exit 1
fi

# ── Read dimensions ──────────────────────────────────────────────────
WIDTH=$(sips -g pixelWidth "$IMAGE" | tail -1 | awk '{print $2}')
HEIGHT=$(sips -g pixelHeight "$IMAGE" | tail -1 | awk '{print $2}')
echo "Dimensions: ${WIDTH}x${HEIGHT}"

# ── Determine content type ───────────────────────────────────────────
EXT="${IMAGE##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
case "$EXT" in
  jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
  png)      CONTENT_TYPE="image/png" ;;
  webp)     CONTENT_TYPE="image/webp" ;;
  tiff|tif) CONTENT_TYPE="image/tiff" ;;
  avif)     CONTENT_TYPE="image/avif" ;;
  *)
    echo "Error: unsupported format: $EXT" >&2
    exit 1
    ;;
esac

# ── Build R2 key ─────────────────────────────────────────────────────
FILENAME=$(basename "$IMAGE")
R2_KEY="$FILENAME"
R2_URL="${R2_BASE_URL}/${R2_KEY}"

# ── Upload to R2 ─────────────────────────────────────────────────────
echo "Uploading to R2: ${R2_BUCKET}/${R2_KEY}"
wrangler r2 object put "${R2_BUCKET}/${R2_KEY}" \
  --file="$IMAGE" \
  --content-type="$CONTENT_TYPE"

# ── Add entry to photos.ts ───────────────────────────────────────────
# Escape single quotes in alt text for the TS string
ALT_ESCAPED="${ALT//\'/\\\'}"

NEW_ENTRY="  { src: '${R2_URL}', alt: '${ALT_ESCAPED}', width: ${WIDTH}, height: ${HEIGHT} },"

# Insert before the closing ];
sed -i '' "/^];$/i\\
${NEW_ENTRY}
" "$PHOTOS_TS"

echo ""
echo "Done! Added to ${PHOTOS_TS}:"
echo "  ${NEW_ENTRY}"
echo ""
echo "Next: review the change, then commit and push."
