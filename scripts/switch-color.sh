#!/usr/bin/env bash
set -euo pipefail

COLOR=${1:-}
if [[ -z "$COLOR" ]]; then
  echo "Usage: $0 <blue|green>"
  exit 1
fi

if [[ "$COLOR" != "blue" && "$COLOR" != "green" ]]; then
  echo "Color must be 'blue' or 'green'"
  exit 1
fi

ENV_FILE=.env
if [[ ! -f $ENV_FILE ]]; then
  echo ".env not found. Copy .env.sample and fill in required values first."
  exit 1
fi

python3 - "$ENV_FILE" "$COLOR" <<'PY'
import sys
from pathlib import Path
path = Path(sys.argv[1])
color = sys.argv[2]
lines = path.read_text().splitlines()
out = []
updated = False
for line in lines:
    if line.startswith('ACTIVE_COLOR='):
        out.append(f'ACTIVE_COLOR={color}')
        updated = True
    else:
        out.append(line)
if not updated:
    out.append(f'ACTIVE_COLOR={color}')
path.write_text('\n'.join(out) + '\n')
PY

docker compose -f docker-compose.bluegreen.yml up -d proxy

echo "Proxy now routing traffic to $COLOR environment"
