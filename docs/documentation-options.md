# Documentation Options

The `documentation` hash in entity exposures supports the following options:

## Type Options

| Option | Description | Example |
|--------|-------------|---------|
| `type` | OpenAPI data type | `String`, `Integer`, `Boolean`, `Float`, `Date`, `DateTime` |
| `is_array` | Marks field as array type | `true` / `false` |
| `additional_properties` | Schema for free-form object values (maps) | `true`, `String`, `'string'`, `SomeEntity` |

## Description Options

| Option | Description | Example |
|--------|-------------|---------|
| `desc` | Property description | `'User email address'` |
| `example` | Example value for documentation | `'user@example.com'` |
| `default` | Default value | `'pending'` |

## Validation Options

| Option | Description | Example |
|--------|-------------|---------|
| `required` | Whether field is required | `true` / `false` |
| `values` | Enum values (array or proc) | `%w[pending active]` or `-> { Status.all }` |
| `minimum` | Minimum value for numeric types | `0` |
| `maximum` | Maximum value for numeric types | `100` |
| `min_length` | Minimum length for strings | `1` |
| `max_length` | Maximum length for strings | `255` |
| `min_items` | Minimum items for arrays | `1` |
| `max_items` | Maximum items for arrays | `10` |
| `unique_items` | Array items must be unique | `true` |

## Display Options

| Option | Description | Example |
|--------|-------------|---------|
| `read_only` | Marks field as read-only | `true` |
| `hidden` | Hide field from documentation | `true` |

## Examples

### Basic types

```ruby
expose :id, documentation: { type: Integer, desc: 'Unique identifier' }
expose :name, documentation: { type: String, desc: 'Full name', required: true }
expose :active, documentation: { type: Boolean, default: true }
```

### Enums

```ruby
expose :status, documentation: {
  type: String,
  desc: 'Current status',
  values: %w[pending active suspended]
}
```

### Numeric constraints

```ruby
expose :age, documentation: {
  type: Integer,
  minimum: 0,
  maximum: 150
}
```

### String constraints

```ruby
expose :username, documentation: {
  type: String,
  min_length: 3,
  max_length: 20
}
```

### Arrays

```ruby
expose :tags, documentation: {
  type: String,
  is_array: true,
  desc: 'Associated tags'
}
```

### Additional properties (maps)

For object-typed fields whose values follow a single schema (e.g. a string-to-string map),
use `additional_properties` to set the OpenAPI [`additionalProperties`](https://swagger.io/specification/v2/#model-with-mapdictionary-properties)
key on the resulting schema.

```ruby
# Allow any additional properties
expose :metadata, documentation: { type: Hash, additional_properties: true }

# Allow any additional properties of a particular type (Ruby class or type name)
expose :counts,   documentation: { type: Hash, additional_properties: Integer }
expose :tags,     documentation: { type: 'object', additional_properties: 'string' }

# Allow any additional properties matching a defined entity
expose :widgets,  documentation: { type: Hash, additional_properties: WidgetEntity }
```
