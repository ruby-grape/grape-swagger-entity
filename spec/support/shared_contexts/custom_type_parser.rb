# frozen_string_literal: true

CustomType = Class.new

class CustomTypeParser
  attr_reader :model, :endpoint

  def initialize(model, endpoint)
    @model = model
    @endpoint = endpoint
  end

  def call
    {
      model.name.to_sym => {
        type: 'custom_type',
        description: "it's a custom type",
        data: {
          name: model.name
        }
      }
    }
  end
end

GrapeSwagger.model_parsers.register(CustomTypeParser, CustomType)
