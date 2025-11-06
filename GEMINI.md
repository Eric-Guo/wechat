# Gemini Project Context: wechat

## Project Overview

This project is a Ruby gem named `wechat`. It provides a comprehensive DSL (Domain-Specific Language) and API for integrating Ruby on Rails applications with various WeChat platforms, including:

*   WeChat Official Accounts Platform
*   WeChat Enterprise Accounts (WeCom)
*   WeChat Mini Programs

The gem simplifies handling WeChat callbacks, messaging, JSSDK configuration, and OAuth 2.0 authentication. It also provides a standalone command-line interface (`wechat`) for interacting with the WeChat API directly.

## Key Technologies

*   **Language:** Ruby (>= 2.7)
*   **Framework:** Primarily for Ruby on Rails (>= 6.0), with support for older versions.
*   **HTTP Client:** `httpx`
*   **XML Parsing:** `nokogiri`
*   **CLI:** `thor`
*   **Testing:** RSpec
*   **Code Style:** RuboCop

## Building and Running

### 1. Setup

Install the required dependencies using Bundler:

```bash
bundle install
```

### 2. Running Tests

The project uses RSpec for testing. To run the full test suite, use one of the following commands:

```bash
# Using bundler
bundle exec rspec

# Using the rake task
rake spec
```

### 3. Code Style and Linting

The project uses RuboCop to enforce code style. To check for offenses:

```bash
# Using bundler
bundle exec rubocop

# Using the rake task
rake rubocop
```

### 4. Default Rake Task

A default `rake` task is configured to run both the test suite and the linter:

```bash
rake
```

## Development Conventions

*   **Rails Integration:** The gem is designed to integrate tightly with Rails, providing generators (`rails g wechat:install`) to create configuration files (`config/wechat.yml`), controllers, and initializers.
*   **Responder DSL:** A key feature is the `wechat_responder` DSL in controllers, which allows for an event-driven approach to handling incoming messages and events from WeChat.
*   **API Access:** The `Wechat.api` object provides direct access to the WeChat API for use in any part of a Rails application, including ActiveJob or Rake tasks.
*   **Command-Line Interface:** A `wechat` executable is included for performing API actions directly from the shell, configured via `~/.wechat.yml` or project-level `config/wechat.yml`.
*   **CI/CD:** The `.gitlab-ci.yml` file defines the continuous integration pipeline, which validates pushes and merge requests by running `rspec` and `rubocop`.
