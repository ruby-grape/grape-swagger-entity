# Architecture Overview

## Purpose

This gem registers a model parser with grape-swagger that converts `Grape::Entity` classes into OpenAPI schema definitions.

## Core Components

```
lib/grape-swagger/entity/
├── parser.rb           # Main parser - converts Entity to OpenAPI schema
├── attribute_parser.rb # Parses individual exposure attributes
├── helper.rb           # Utility methods for model naming, discriminators
└── version.rb          # Gem version
```

### Parser (`parser.rb`)

Entry point for entity parsing. Responsibilities:
- Extract exposures from Grape::Entity
- Handle nested entities and `using:` references
- Process `merge: true` exposures
- Handle inheritance with `allOf` and discriminators
- Determine required fields

### AttributeParser (`attribute_parser.rb`)

Converts individual exposure options to OpenAPI property schema:
- Maps Ruby types to OpenAPI types
- Handles arrays (`is_array: true`)
- Processes enums (`values:`)
- Adds constraints (min/max, minLength/maxLength)

### Helper (`helper.rb`)

Utilities for:
- Model name resolution (strips Entity/Entities suffix)
- Discriminator detection for inheritance
- Root exposure extraction

## Data Flow

```
Grape::Entity class
       │
       ▼
   Parser.call
       │
       ├── extract_params (get exposures)
       │
       ├── parse_grape_entity_params
       │         │
       │         ├── AttributeParser (per exposure)
       │         │
       │         └── parse_nested (for nested blocks)
       │
       └── handle_discriminator (inheritance)
       │
       ▼
[properties_hash, required_array]
```

## Integration Point

Registered with grape-swagger in `lib/grape-swagger/entity.rb`:

```ruby
GrapeSwagger.model_parsers.register(GrapeSwagger::Entity::Parser, Grape::Entity)
```

grape-swagger calls `Parser.new(model, endpoint).call` when it encounters a `Grape::Entity` subclass.
