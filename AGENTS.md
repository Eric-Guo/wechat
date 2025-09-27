# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the gem source; keep entrypoints like `lib/wechat.rb` lean and delegate to domain modules.
- `lib/wechat/` includes API clients (`api.rb`, `http_client.rb`), token helpers, and responders—group new features here by domain.
- `lib/action_controller/` and `lib/generators/` provide Rails integrations; mirror their structure when adding framework glue.
- `spec/` contains RSpec suites with a `spec/dummy/` Rails app for integration fixtures; keep new specs beside the code they verify.
- `bin/` hosts Bundler-generated executables; `pkg/` and `coverage/` are build outputs and should stay out of commits.

## Build, Test, and Development Commands
- `bundle install` prepares dependencies defined in the `Gemfile`.
- `bundle exec rake` runs the default suite (`spec` + `rubocop`) and serves as the pre-push gate.
- `bundle exec rake spec` executes all RSpec examples; add `SPEC=spec/lib/wechat/http_client_spec.rb` to target a subset.
- `bundle exec rubocop` enforces the shared style guide; fix or justify any deviations before review.
- `bundle exec rspec spec/lib/wechat/http_client_spec.rb` is a typical focused run—swap in the file you are modifying.

## Coding Style & Naming Conventions
- Follow standard Ruby style: two-space indents, `snake_case` methods, `CamelCase` classes/modules, and predicate methods ending in `?`.
- Keep public API files grouped under `lib/wechat/` and prefer descriptive suffixes such as `_api.rb`, `_client.rb`, or `_responder.rb`.
- RuboCop (TargetRuby 2.5, 180-column limit) is authoritative; run it before committing and accept auto-corrections only when they stay readable.
- Add frozen-string literals to new files and align constants/messages with existing naming patterns.

## Testing Guidelines
- Use RSpec with shared helpers from `spec/support/`; mimic existing example structure when introducing new contexts.
- Name specs after the source file (`wechat/http_client_spec.rb`) and place integration scenarios inside `spec/dummy/` when they depend on Rails wiring.
- Aim to keep SimpleCov coverage steady; re-run `bundle exec rake spec` after major refactors and inspect `coverage/index.html` locally.

## Commit & Pull Request Guidelines
- Write concise, imperative commit subjects similar to `Bump rubocop.` or `Add corp API timeout guard`; add a blank line before body details.
- Reference related issues with `#123` and note any breaking changes explicitly in the message body.
- Before opening a PR, run `bundle exec rake`, update relevant docs, and include a short testing checklist plus screenshots for UI-facing changes.
- Provide context for maintainers: summarize motivation, list follow-up steps if work is staged, and keep PRs focused on a single feature or fix.
