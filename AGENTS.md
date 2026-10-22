# AGENTS.md

## Cursor Cloud specific instructions

This is a Rails 8.1 monolith ("Herve 2") with PostgreSQL, Tailwind CSS, and Hotwire/Stimulus. No npm/yarn is used — JavaScript is managed via importmap.

### Services

| Service | How to start |
|---------|-------------|
| PostgreSQL 16 | `sudo pg_ctlcluster 16 main start` |
| Rails + Tailwind (dev) | `sudo PORT=3000 bin/dev` (runs Puma + Tailwind watcher via foreman) |

### Key commands

- **Lint:** `bundle exec rubocop` (CI uses `bin/rubocop -f github`)
- **Tests:** `bin/rails test` (requires DB: `bin/rails db:test:prepare`)
- **Security scan:** `bundle exec brakeman --no-pager`
- **Dev server:** `bin/dev` (port 3000 by default)

### Non-obvious notes

- The `bin/brakeman` binstub exits non-zero when a newer version exists. Use `bundle exec brakeman` instead for clean exit codes.
- PostgreSQL must be started manually in the Cloud VM: `sudo pg_ctlcluster 16 main start`
- Databases are `herve_2_development` and `herve_2_test`. Create with `bin/rails db:create` if missing.
- The `docker-compose.yml` maps port 3008→3000. When running natively, the app listens on port 3000 directly.
- Tailwind CSS is compiled by the `tailwindcss-rails` gem (no Node.js build step needed).
- Foreman gem must be installed globally (`gem install foreman`) since `bin/dev` auto-installs it.
- Run `sudo bundle install` (gems install to `/usr/local/lib/ruby/gems/`).
