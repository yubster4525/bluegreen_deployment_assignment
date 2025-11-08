#!/usr/bin/env bash
set -euo pipefail

COLOR=${1:-}
IMAGE_OVERRIDE=${2:-}
VERSION_OVERRIDE=${3:-}

if [[ -z "$COLOR" ]]; then
  echo "Usage: $0 <blue|green> [image] [version]"
  exit 1
fi
if [[ "$COLOR" != "blue" && "$COLOR" != "green" ]]; then
  echo "Color must be 'blue' or 'green'"
  exit 1
fi

ENV_FILE=.env
if [[ ! -f $ENV_FILE ]]; then
  echo "Missing .env file"
  exit 1
fi

source $ENV_FILE

IMAGE_VAR_NAME=$(echo "${COLOR}_IMAGE" | tr '[:lower:]' '[:upper:]')
VERSION_VAR_NAME=$(echo "${COLOR}_VERSION" | tr '[:lower:]' '[:upper:]')
SERVICE_NAME=$COLOR

CURRENT_IMAGE=${IMAGE_OVERRIDE:-${!IMAGE_VAR_NAME}}
CURRENT_VERSION=${VERSION_OVERRIDE:-${!VERSION_VAR_NAME}}

if [[ -z "$CURRENT_IMAGE" ]]; then
  echo "Define $IMAGE_VAR_NAME in .env or pass an image reference"
  exit 1
fi

python3 - "$ENV_FILE" "$IMAGE_VAR_NAME" "$CURRENT_IMAGE" "$VERSION_VAR_NAME" "$CURRENT_VERSION" <<'PY'
import sys
from pathlib import Path
path = Path(sys.argv[1])
image_var, image_value, version_var, version_value = sys.argv[2:]
lines = path.read_text().splitlines()
out = []
seen = {image_var: False, version_var: False}
for line in lines:
    if '=' not in line:
        out.append(line)
        continue
    key, value = line.split('=', 1)
    if key == image_var:
        out.append(f"{key}={image_value}")
        seen[image_var] = True
    elif key == version_var:
        out.append(f"{key}={version_value}")
        seen[version_var] = True
    else:
        out.append(line)
if not seen[image_var]:
    out.append(f"{image_var}={image_value}")
if not seen[version_var]:
    out.append(f"{version_var}={version_value}")
path.write_text('\n'.join(out) + '\n')
PY

env "${IMAGE_VAR_NAME}=$CURRENT_IMAGE" "${VERSION_VAR_NAME}=$CURRENT_VERSION" docker compose -f docker-compose.bluegreen.yml up -d $SERVICE_NAME

echo "Deployed $SERVICE_NAME environment with image $CURRENT_IMAGE (version $CURRENT_VERSION)"
