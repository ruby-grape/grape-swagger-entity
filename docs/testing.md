# Testing Patterns

## Running Tests

```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path/file.rb  # Run specific file
bundle exec rspec -e "description"   # Run matching examples
```

## Test Structure

```
spec/
├── grape-swagger/
│   ├── entity_spec.rb              # Main module specs
│   ├── entity/
│   │   ├── parser_spec.rb          # Parser unit tests
│   │   └── attribute_parser_spec.rb
│   └── entities/
│       └── response_model_spec.rb  # Integration tests
├── issues/                          # Regression tests for GitHub issues
│   └── 962_polymorphic_entity_...   # Named by issue number
└── support/
    └── shared_contexts/             # Reusable test setup
```

## Shared Contexts

Use shared contexts for common API setups:

```ruby
require 'spec_helper'
require_relative '../../support/shared_contexts/this_api'

describe SomeClass do
  include_context 'this api'
  # ...
end
```

## Issue Regression Tests

When fixing a bug, create a spec in `spec/issues/` named `{issue_number}_{brief_description}_spec.rb`:

```ruby
# spec/issues/123_some_bug_spec.rb
require 'spec_helper'

describe '#123 brief description of the issue' do
  # Test that reproduces and verifies the fix
end
```

## Testing with Different Gem Versions

Environment variables control dependency versions:

```bash
GRAPE_VERSION=2.0.0 bundle update grape
GRAPE_SWAGGER_VERSION=HEAD bundle update grape-swagger
GRAPE_ENTITY_VERSION=1.0.1 bundle update grape-entity
```
