## Upgrading grape-swagger-entity

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
