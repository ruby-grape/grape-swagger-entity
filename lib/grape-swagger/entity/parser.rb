module GrapeSwagger
  module Entity
    class Parser
      attr_reader :model
      attr_reader :endpoint

      def initialize(model, endpoint)
        @model = model
        @endpoint = endpoint
      end

      def call
        parameters = model.root_exposures.each_with_object({}) do |value, memo|
          memo[value.attribute] = value.send(:options)
        end

        parse_grape_entity_params(parameters)
      end

      private

      def parse_grape_entity_params(params, parent_model = nil)
        return unless params

        params.each_with_object({}) do |(entity_name, entity_options), memo|
          next if entity_options.fetch(:documentation, {}).fetch(:in, nil).to_s == 'header'

          entity_name = entity_options[:as] if entity_options[:as]
          documentation = entity_options[:documentation]
          entity_model = model_from(entity_options)

          if entity_model
            name = endpoint.nil? ? entity_model.to_s.demodulize : endpoint.send(:expose_params_from_model, entity_model)
            memo[entity_name] = entity_model_type(name, entity_options)
          elsif entity_options[:nesting]
            memo[entity_name] = parse_nested(entity_name, entity_options, parent_model)
          else
            memo[entity_name] = data_type_from(entity_options)
            next unless documentation

            memo[entity_name][:default] = documentation[:default] if documentation[:default]

            if (values = documentation[:values])
              memo[entity_name][:enum] = values if values.is_a?(Array)
            end

            if documentation[:is_array]
              memo[entity_name] = {
                type: :array,
                items: memo.delete(entity_name)
              }
            end
          end

          if documentation
            memo[entity_name][:read_only] = documentation[:read_only].to_s == 'true' if documentation[:read_only]
            memo[entity_name][:description] = documentation[:desc] if documentation[:desc]
          end
        end
      end

      def model_from(entity_options)
        model = entity_options[:using] if entity_options[:using].present?

        if could_it_be_a_model?(entity_options[:documentation])
          model ||= entity_options[:documentation][:type]
        end

        model
      end

      def parse_nested(entity_name, entity_options, parent_model = nil)
        nested_entity = if parent_model.nil?
                          model.root_exposures.find_by(entity_name)
                        else
                          parent_model.nested_exposures.find_by(entity_name)
                        end

        params = nested_entity.nested_exposures.each_with_object({}) do |value, memo|
          memo[value.attribute] = value.send(:options)
        end

        properties = parse_grape_entity_params(params, nested_entity)
        is_a_collection = entity_options[:documentation].is_a?(Hash) &&
                          entity_options[:documentation][:type].to_s.casecmp('array').zero?

        if is_a_collection
          {
            type: :array,
            items: {
              type: :object,
              properties: properties
            },
            description: entity_options[:desc] || ''
          }
        else
          {
            type: :object,
            properties: properties,
            description: entity_options[:desc] || ''
          }
        end
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
    end
  end
end
