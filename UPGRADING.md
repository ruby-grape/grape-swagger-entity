## Upgrading grape-swagger-entity

### Upgrading to >= 0.7.1

#### Non-Array Entity References Now Use `allOf` Wrapper

This release fixes an issue where `description` and `readOnly` properties were silently
ignored for non-array entity references. The fix wraps `$ref` in an `allOf` array,
which is the correct way to combine `$ref` with sibling properties per OpenAPI/JSON Schema spec.

**Previous Output (invalid OpenAPI - description was ignored):**
```json
{
  "user": {
    "$ref": "#/definitions/User",
    "description": "The author"
  }
}
```

**New Output (valid OpenAPI):**
```json
{
  "user": {
    "allOf": [{ "$ref": "#/definitions/User" }],
    "description": "The author"
  }
}
```

**Note:** Array entity references are not affected - they already supported sibling
properties via the `items` wrapper.

**Action Required:**
If you have code or tests that parse the raw Swagger/OpenAPI output and expect
`$ref` at the top level for entity references with `description` or `readOnly`,
update them to handle the `allOf` wrapper.

For more details, refer to GitHub Pull Request
[#90](https://github.com/ruby-grape/grape-swagger-entity/pull/90).

### Upgrading to >= 0.7.0

#### Entity Fields Required by Default

This release changes how `grape-swagger-entity` determines if an entity field is
**required** in the generated Swagger documentation. This is a **breaking change**
and may require updates to your API documentation and any tools or tests that rely
on the previous behavior.

**Previous Behavior:**
Fields were considered optional by default unless explicitly marked as `required: true`
in their `documentation` options.

**New Behavior:**
Fields are now considered **required by default** unless one of the following
conditions is met:

1.  **`documentation: { required: false }` is explicitly set:** If you want a field to
    be optional, you must now explicitly set `required: false` within its
    `documentation` hash.
    ```ruby
    expose :field_name,
           documentation: { type: String, required: false, desc: 'An optional field' }
    ```
2.  **`if` or `unless` options are present:** If a field uses `if` or `unless` for
    conditional exposure, it will be considered optional.
    ```ruby
    expose :conditional_field,
           if: -> { some_condition? },
           documentation: { type: String, desc: 'Exposed only if condition is met' }
    ```
3.  **`expose_nil: false` is set:** If `expose_nil` is set to `false`, the field will
    be considered optional.
    ```ruby
    expose :non_nil_field,
           expose_nil: false,
           documentation: { type: String, desc: 'Not exposed if nil' }
    ```

This change aligns `grape-swagger-entity`'s behavior with `grape-entity`'s rendering
logic, where fields are always exposed unless `if` or `unless` is provided.

**Action Required:**
Review your existing Grape entities. If you have fields that were implicitly
considered optional but did not explicitly set `required: false`, `if`, `unless`, or
`expose_nil: false`, they will now be marked as required in your Swagger
documentation.Adjust your `documentation` options accordingly to maintain the desired
optionality for these fields.

For more details, refer to GitHub Pull Request
[#81](https://github.com/ruby-grape/grape-swagger-entity/pull/81).
````
