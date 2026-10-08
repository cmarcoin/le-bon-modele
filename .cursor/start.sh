#!/usr/bin/env bash
# Per-boot Cloud Agent start: bring PostgreSQL up. Do not install gems here.
set -euo pipefail

if [ -f /etc/profile.d/le-bon-modele.sh ]; then
  # shellcheck disable=SC1091
  source /etc/profile.d/le-bon-modele.sh
fi

export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${PATH:-/usr/bin}"
export DATABASE_HOST="${DATABASE_HOST:-localhost}"
export DATABASE_PORT="${DATABASE_PORT:-5432}"
export DATABASE_NAME="${DATABASE_NAME:-herve_2}"
export DATABASE_USERNAME="${DATABASE_USERNAME:-postgres}"
export DATABASE_PASSWORD="${DATABASE_PASSWORD:-password}"

if ! command -v pg_lsclusters >/dev/null 2>&1; then
  echo "PostgreSQL is not installed; run the environment install script first." >&2
  exit 1
fi

if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
  ver="$(pg_lsclusters --no-header | awk 'NR==1 { print $1 }')"
  name="$(pg_lsclusters --no-header | awk 'NR==1 { print $2 }')"
  sudo pg_ctlcluster "${ver}" "${name}" start
fi

for _ in $(seq 1 30); do
  if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "PostgreSQL is ready on localhost:5432"
    exit 0
  fi
  sleep 1
done

echo "PostgreSQL did not become ready on localhost:5432" >&2
exit 1
