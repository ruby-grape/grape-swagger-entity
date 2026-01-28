# GrapeSwagger::Entity

[![Gem Version](https://badge.fury.io/rb/grape-swagger-entity.svg)](https://badge.fury.io/rb/grape-swagger-entity)
[![Build Status](https://github.com/ruby-grape/grape-swagger-entity/actions/workflows/test.yml/badge.svg)](https://github.com/ruby-grape/grape-swagger-entity/actions/workflows/test.yml)

## Table of Contents

- [What is grape-swagger-entity?](#what-is-grape-swagger-entity)
- [Related Projects](#related-projects)
- [Compatibility](#compatibility)
- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## What is grape-swagger-entity?

This gem provides an adapter for [grape-swagger](https://github.com/ruby-grape/grape-swagger) that allows parsing [grape-entity](https://github.com/ruby-grape/grape-entity) classes to generate OpenAPI/Swagger model definitions automatically.

### What it does

- Generates `definitions` in your Swagger JSON from Grape::Entity exposures
- Maps entity properties to OpenAPI schema properties with types and descriptions
- Handles nested entities and entity references via `$ref`
- Supports arrays, required fields, and documentation options

### Example Output

```json
{
  "definitions": {
    "User": {
      "type": "object",
      "description": "User model",
      "properties": {
        "id": { "type": "integer", "description": "User ID" },
        "name": { "type": "string", "description": "Full name" }
      },
      "required": ["id", "name"]
    }
  }
}
```

## Related Projects

- [Grape](https://github.com/ruby-grape/grape)
- [Grape Entity](https://github.com/ruby-grape/grape-entity)
- [Grape Swagger](https://github.com/ruby-grape/grape-swagger)
- [Grape Swagger Representable](https://github.com/ruby-grape/grape-swagger-representable)

## Compatibility

This gem is tested with the following versions:

| grape-swagger-entity | grape-swagger | grape-entity | grape   |
|---------------------|---------------|--------------|---------|
| 0.7.x               | >= 1.2.0      | >= 0.6.0     | >= 1.3  |
| 0.6.x               | >= 1.2.0      | >= 0.6.0     | >= 1.3  |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-swagger-entity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-swagger-entity

## Usage

### Basic Entity

Define your entities with `documentation` options to generate OpenAPI schema properties:

```ruby
class UserEntity < Grape::Entity
  expose :id, documentation: { type: Integer, desc: 'User ID' }
  expose :name, documentation: { type: String, desc: 'Full name' }
  expose :email, documentation: { type: String, desc: 'Email address' }
end
```

### Custom Model Description

Override the default "{ModelName} model" description by defining a `self.documentation` method (requires grape-swagger >= 2.2.0):

```ruby
class UserEntity < Grape::Entity
  def self.documentation
    { desc: 'Represents a user account with profile information' }
  end

  expose :id, documentation: { type: Integer, desc: 'User ID' }
  expose :name, documentation: { type: String, desc: 'Full name' }
end
```

### Entity References

Use `using:` to reference other entities and `is_array:` for collections:

```ruby
class OrderEntity < Grape::Entity
  expose :id, documentation: { type: Integer, desc: 'Order ID' }
  expose :user, using: UserEntity,
         documentation: { desc: 'The customer who placed this order' }
  expose :items, using: ItemEntity,
         documentation: { desc: 'Line items', is_array: true }
end
```

### Documentation Options

Common options: `type`, `desc`, `required`, `is_array`, `values`, `example`.

See [full documentation options](docs/documentation-options.md) for all available options including validation constraints.

## Development

See [testing documentation](docs/testing.md) for development setup and running tests.

## Contributing

See [contributing guidelines](docs/contributing.md).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
