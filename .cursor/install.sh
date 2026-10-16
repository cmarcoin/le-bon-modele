#!/usr/bin/env bash
# Idempotent Cloud Agent / native bootstrap for le-bon-modele (Rails 8.1 + PostgreSQL).
# Installs Ruby 3.3.9, Bundler, PostgreSQL, gems, and prepares the database.
# Does not start the Rails server (that belongs in start/terminals).
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  APP_ROOT="${APP_ROOT:-/workspace}"
fi
cd "$APP_ROOT"

RUBY_VERSION="$(tr -d '[:space:]' < .ruby-version | sed 's/^ruby-//')"
BUNDLER_VERSION="$(awk 'f{print $1; exit} /^BUNDLED WITH$/{f=1}' Gemfile.lock)"

ensure_profile() {
  sudo tee /etc/profile.d/le-bon-modele.sh >/dev/null <<'EOF'
export PATH="/home/ubuntu/.local/share/mise/shims:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DATABASE_HOST="${DATABASE_HOST:-localhost}"
export DATABASE_PORT="${DATABASE_PORT:-5432}"
export DATABASE_NAME="${DATABASE_NAME:-herve_2}"
export DATABASE_USERNAME="${DATABASE_USERNAME:-postgres}"
export DATABASE_PASSWORD="${DATABASE_PASSWORD:-password}"
EOF
  sudo chmod 644 /etc/profile.d/le-bon-modele.sh
  # shellcheck disable=SC1091
  source /etc/profile.d/le-bon-modele.sh

  if [ -f /home/ubuntu/.bashrc ] && ! grep -q 'le-bon-modele.sh' /home/ubuntu/.bashrc; then
    printf '\n# le-bon-modele cloud agent env\n[ -f /etc/profile.d/le-bon-modele.sh ] && . /etc/profile.d/le-bon-modele.sh\n' >> /home/ubuntu/.bashrc
  fi
}

install_system_packages() {
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    libffi-dev \
    libpq-dev \
    libreadline-dev \
    libssl-dev \
    libvips42 \
    libyaml-dev \
    pkg-config \
    postgresql \
    postgresql-client \
    postgresql-contrib \
    zlib1g-dev
}

install_ruby() {
  export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${PATH}"
  if command -v ruby >/dev/null 2>&1 && ruby -e "exit(RUBY_VERSION == '${RUBY_VERSION}' ? 0 : 1)"; then
    echo "Ruby ${RUBY_VERSION} already installed: $(ruby -v)"
    return 0
  fi

  if [ ! -x "${HOME}/.local/bin/mise" ]; then
    curl -fsSL https://mise.run | sh
  fi
  export PATH="${HOME}/.local/bin:${PATH}"
  mise install "ruby@${RUBY_VERSION}"
  mise use -g "ruby@${RUBY_VERSION}"
  eval "$(mise activate bash --shims)"
  ruby -v
}

install_gems() {
  export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${PATH}"
  gem install bundler -v "${BUNDLER_VERSION}" --no-document
  bundle config set --local frozen true
  bundle install --jobs "$(nproc)" --retry 3
  gem install foreman --no-document
}

ensure_app_env() {
  if [ ! -f .env ]; then
    cat > .env <<'EOF'
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=herve_2
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
CONTACT_RECIPIENT=contact@lebonmodele.fr
EOF
  fi

  export DATABASE_HOST="${DATABASE_HOST:-localhost}"
  export DATABASE_PORT="${DATABASE_PORT:-5432}"
  export DATABASE_NAME="${DATABASE_NAME:-herve_2}"
  export DATABASE_USERNAME="${DATABASE_USERNAME:-postgres}"
  export DATABASE_PASSWORD="${DATABASE_PASSWORD:-password}"
}

start_postgres_for_setup() {
  local ver name
  if ! command -v pg_lsclusters >/dev/null 2>&1; then
    echo "pg_lsclusters not found after postgresql install" >&2
    exit 1
  fi
  ver="$(pg_lsclusters --no-header | awk 'NR==1 { print $1 }')"
  name="$(pg_lsclusters --no-header | awk 'NR==1 { print $2 }')"
  if [ -z "${ver}" ] || [ -z "${name}" ]; then
    echo "No PostgreSQL cluster found" >&2
    pg_lsclusters >&2 || true
    exit 1
  fi
  if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    sudo pg_ctlcluster "${ver}" "${name}" start
  fi
  for _ in $(seq 1 30); do
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
  pg_isready -h localhost -p 5432

  sudo -u postgres psql -v ON_ERROR_STOP=1 -c "ALTER USER postgres WITH PASSWORD '${DATABASE_PASSWORD}';"
}

prepare_database() {
  export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${PATH}"
  export DATABASE_HOST="${DATABASE_HOST:-localhost}"
  export DATABASE_PORT="${DATABASE_PORT:-5432}"
  export DATABASE_NAME="${DATABASE_NAME:-herve_2}"
  export DATABASE_USERNAME="${DATABASE_USERNAME:-postgres}"
  export DATABASE_PASSWORD="${DATABASE_PASSWORD:-password}"
  bin/rails db:prepare
  bin/rails db:seed
  bin/rails tailwindcss:build
}

ensure_profile
install_system_packages
install_ruby
install_gems
ensure_app_env
start_postgres_for_setup
prepare_database

echo "Cloud agent install completed."
echo "ruby: $(ruby -v)"
echo "bundler: $(bundle -v)"
echo "postgres: $(psql --version)"
