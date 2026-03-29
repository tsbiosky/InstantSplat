#!/bin/bash
# Copy images from custom_Dataset into InstantSplat's expected layout.
# Run on server: bash setup_custom_dataset.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="/workspace/custom_Dataset/inputs"
DST_DIR="${SCRIPT_DIR}/assets/custom/indoor/images"

mkdir -p "${DST_DIR}"

# Copy all 29 input images
for i in $(seq 0 28); do
    cp "${SRC_DIR}/rgb_${i}.png" "${DST_DIR}/rgb_$(printf '%03d' ${i}).png"
done

echo "Copied 29 images to ${DST_DIR}"
echo "Contents:"
ls -la "${DST_DIR}/"
