# Contributing Guidelines

## PR Requirements

Every PR must include:

1. **CHANGELOG.md entry** - Add under `### X.X.X (Next)` in the appropriate section:
   ```markdown
   #### Fixes
   * [#123](https://github.com/ruby-grape/grape-swagger-entity/pull/123): Brief description - [@username](https://github.com/username).
   ```

2. **Passing CI** - RuboCop + RSpec must pass

3. **Tests** - New functionality needs specs; bug fixes need regression tests

## CHANGELOG Format

```markdown
### 0.7.1 (Next)

#### Features

* Your contribution here.

#### Fixes

* [#PR](URL): Description - [@author](URL).
```

- Use `Features` for new functionality
- Use `Fixes` for bug fixes and maintenance

## Commit Messages

Follow conventional style:
- `Fix #123: description` for bug fixes
- `Add feature description` for features
- `Update dependency/docs` for maintenance

## Code Style

RuboCop enforces style. Key rules:
- `frozen_string_literal: true` pragma required
- Consistent hash indentation
- No trailing whitespace

```bash
bundle exec rubocop -a  # Auto-fix most issues
```

## Danger Checks

CI runs danger which enforces:
- CHANGELOG entry present
- Table of Contents in README is current
- PR has description
