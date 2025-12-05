# Rails New Command Options Reference

This document lists all available options for the `rails-new` executable (which accepts the same options as `rails new`).

## Database Options

- `--database=postgresql` - Use PostgreSQL (default: sqlite3)
- `--database=mysql` - Use MySQL
- `--database=sqlite3` - Use SQLite3 (default)
- `--database=oracle` - Use Oracle
- `--database=sqlserver` - Use SQL Server
- `--database=jdbcmysql` - Use JDBC MySQL
- `--database=jdbcsqlite3` - Use JDBC SQLite3
- `--database=jdbcpostgresql` - Use JDBC PostgreSQL
- `--database=trilogy` - Use Trilogy

## CSS Framework Options

- `--css=tailwind` - Use Tailwind CSS
- `--css=bootstrap` - Use Bootstrap
- `--css=bulma` - Use Bulma
- `--css=postcss` - Use PostCSS
- `--css=sass` - Use Sass
- `--css=scss` - Use SCSS
- `--skip-asset-pipeline` - Skip the asset pipeline

## JavaScript Options

- `--javascript=importmap` - Use importmap (default)
- `--javascript=webpack` - Use Webpack
- `--javascript=esbuild` - Use ESBuild
- `--javascript=rollup` - Use Rollup
- `--javascript=bun` - Use Bun
- `--skip-javascript` - Skip JavaScript setup

## Application Type Options

- `--api` - Generate an API-only application
- `--main` - Use the main branch (Rails 7.1+)
- `--edge` - Use the edge version of Rails

## Skip Options

- `--skip-git` - Skip git initialization
- `--skip-gemfile` - Skip Gemfile creation
- `--skip-bundle` - Skip bundle install
- `--skip-test` - Skip test files
- `--skip-system-test` - Skip system test files
- `--skip-jbuilder` - Skip Jbuilder gem
- `--skip-action-mailer` - Skip Action Mailer
- `--skip-action-mailbox` - Skip Action Mailbox
- `--skip-action-text` - Skip Action Text
- `--skip-active-storage` - Skip Active Storage
- `--skip-action-cable` - Skip Action Cable
- `--skip-hotwire` - Skip Hotwire
- `--skip-javascript` - Skip JavaScript setup
- `--skip-asset-pipeline` - Skip asset pipeline
- `--skip-assets` - Skip asset files
- `--skip-listen` - Skip listen gem
- `--skip-spring` - Skip Spring
- `--skip-lock` - Skip Gemfile.lock
- `--skip-bootsnap` - Skip Bootsnap
- `--skip-dev-gems` - Skip development gems
- `--skip-yarn` - Skip Yarn
- `--skip-keeps` - Skip .keep files

## Template Options

- `--template=TEMPLATE` - Path to an application template (file or URL)
- `--template-version=VERSION` - Template version to use

## Other Options

- `--rc=RC` - Path to file containing extra configuration options
- `--name=NAME` - Application name (defaults to directory name)
- `--version` - Show Rails version
- `--help` - Show help message

## Common Usage Examples

### Basic setup with PostgreSQL and Tailwind
```bash
rails-new myapp --database=postgresql --css=tailwind
```

### API-only application
```bash
rails-new myapp --api --database=postgresql
```

### Full stack with ESBuild and Tailwind
```bash
rails-new myapp --database=postgresql --css=tailwind --javascript=esbuild
```

### Minimal setup (skip tests, mailer, etc.)
```bash
rails-new myapp --database=postgresql --css=tailwind --skip-test --skip-action-mailer --skip-action-mailbox
```

### Using a template
```bash
rails-new myapp --database=postgresql --template=https://example.com/template.rb
```

## Notes

- All options from `rails new` work with `rails-new` executable
- You can combine multiple options in a single command
- The `--main` flag uses the latest stable Rails version
- For the most up-to-date list, run: `rails new --help` (or check the [Rails Command Line Guide](https://guides.rubyonrails.org/command_line.html))

