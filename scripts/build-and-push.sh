#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=.env
if [[ ! -f $ENV_FILE ]]; then
  echo "Missing .env file with DOCKERHUB_USERNAME and APP_NAME"
  exit 1
fi

source $ENV_FILE

if [[ -z "${DOCKERHUB_USERNAME:-}" || -z "${APP_NAME:-}" ]]; then
  echo "Populate DOCKERHUB_USERNAME and APP_NAME in .env first"
  exit 1
fi

TAG=${1:-latest}
IMAGE="$DOCKERHUB_USERNAME/$APP_NAME:$TAG"

npm ci --omit=dev

docker build -t "$IMAGE" .

docker push "$IMAGE"

echo "Published image: $IMAGE"
