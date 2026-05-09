# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the gem code: `lib/wechat` contains HTTP clients (`api.rb`, `mp_api.rb`, `corp_api.rb`, `http_client.rb`) plus crypto/responder helpers; `lib/action_controller` provides the Rails responder DSL; `lib/generators` ships installer templates.
- `bin/` contains executable stubs; `spec/` has RSpec suites with the Rails `spec/dummy` app and `spec/support` helpers; coverage output lives in `coverage/`; built gems land in `pkg/`.
- Configuration samples and usage notes are in `README.md` and `README-CN.md`; test certificates sit in `certs/`.

## Build, Test, and Development Commands
- `bundle install` to sync gems.
- `bundle exec rake` runs the default task (`rspec` then `rubocop`).
- `bundle exec rspec spec/lib/wechat/api_spec.rb` for targeted specs; run from repo root so `spec/examples.txt` is respected.
- `bundle exec rubocop` lints `lib/` (specs are excluded by config).

## Coding Style & Naming Conventions
- Target Ruby 2.6; use 2-space indentation, snake_case file names, CamelCase classes/modules; prefer frozen string literals and single quotes.
- Keep lines under 180 chars; break long argument lists; avoid deep nesting (max 4 levels).
- Follow RuboCop (`.rubocop.yml` enables new cops, disables documentation cop). Keep production code lint-clean; use inline disables only with justification.

## Testing Guidelines
- Use RSpec; place tests as `spec/.../*_spec.rb`. Describe behavior in present tense and rely on explicit matchers.
- Specs boot the `spec/dummy` Rails app with an in-memory sqlite schema; avoid real network calls—mock HTTP interactions.
- SimpleCov runs via `spec/spec_helper.rb`; aim to keep coverage steady and clean up generated artifacts from version control.

## Commit & Pull Request Guidelines
- Write concise, imperative commit messages; conventional prefixes (`feat:`, `fix:`, `chore:`) are welcome and present in history.
- Keep commits focused; update docs/examples when APIs or configuration change.

## Cursor Cloud specific instructions

- **System dependencies**: Ruby 3.2, `libsqlite3-dev`, `libyaml-dev`, and `build-essential` are installed via the update script. Gems are installed to `vendor/bundle` (bundler path config is set locally).
- **Running tests + lint**: `bundle exec rake` runs RSpec then RuboCop in one step. See "Build, Test, and Development Commands" above for targeted test/lint commands.
- **CLI usage**: The `wechat` CLI (`bundle exec wechat help`) requires a `~/.wechat.yml` with at least `appid` and `secret` keys. Without valid WeChat credentials, API commands will fail with HTTP errors, but `help` works fine with dummy values.
- **No external services required**: All tests mock HTTP and use in-memory SQLite. No Redis, Docker, or real WeChat API access is needed.
- **Coverage**: SimpleCov output goes to `coverage/index.html`; currently at ~96.5% line coverage.
