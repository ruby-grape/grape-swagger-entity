module GrapeSwagger
  module Entity
    class AttributeParser
      attr_reader :endpoint

      def initialize(endpoint)
        @endpoint = endpoint
      end

      def call(entity_options)
        documentation = entity_options[:documentation]
        entity_model = model_from(entity_options)

        if entity_model
          name = endpoint.nil? ? entity_model.to_s.demodulize : endpoint.send(:expose_params_from_model, entity_model)

          entity_model_type = entity_model_type(name, entity_options)
          return entity_model_type unless documentation

          if documentation[:is_array]
            entity_model_type[:minItems] = documentation[:min_items] if documentation.key?(:min_items)
            entity_model_type[:maxItems] = documentation[:max_items] if documentation.key?(:max_items)
            entity_model_type[:uniqueItems] = documentation[:unique_items] if documentation.key?(:unique_items)
          end

          entity_model_type
        else
          param = data_type_from(entity_options)
          return param unless documentation

          param[:default] = documentation[:default] if documentation[:default]
          add_attribute_example(param, documentation[:example])

          if (values = documentation[:values])
            param[:enum] = values if values.is_a?(Array)
          end

          param = { type: :array, items: param } if documentation[:is_array]
          param
        end
      end

      private

      def model_from(entity_options)
        model = entity_options[:using] if entity_options[:using].present?

        model ||= entity_options[:documentation][:type] if could_it_be_a_model?(entity_options[:documentation])

        model
      end

      def could_it_be_a_model?(value)
        return false if value.nil?

        direct_model_type?(value[:type]) || ambiguous_model_type?(value[:type])
      end

      def direct_model_type?(type)
        type.to_s.include?('Entity') || type.to_s.include?('Entities')
      end

      def ambiguous_model_type?(type)
        type &&
          type.is_a?(Class) &&
          !GrapeSwagger::DocMethods::DataType.primitive?(type.name.downcase) &&
          !type == Array
      end

      def data_type_from(documentation)
        documented_type = documentation[:type]
        documented_type ||= (documentation[:documentation] && documentation[:documentation][:type])

        data_type = GrapeSwagger::DocMethods::DataType.call(documented_type)

        document_data_type(documentation[:documentation], data_type)
      end

      def document_data_type(documentation, data_type)
        type = if GrapeSwagger::DocMethods::DataType.primitive?(data_type)
                 data = GrapeSwagger::DocMethods::DataType.mapping(data_type)
                 { type: data.first, format: data.last }
               else
                 { type: data_type }
               end
        type[:format] = documentation[:format] if documentation && documentation.key?(:format)

        type
      end

      def entity_model_type(name, entity_options)
        if entity_options[:documentation] && entity_options[:documentation][:is_array]
          {
            'type' => 'array',
            'items' => {
              '$ref' => "#/definitions/#{name}"
            }
          }
        else
          {
            '$ref' => "#/definitions/#{name}"
          }
        end
      end

      def add_attribute_example(attribute, example)
        return unless example

        attribute[:example] = example.is_a?(Proc) ? example.call : example
      end
    end
  end
end
