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
        # TODO: this should only be a temporary hack ;)
        if ::GrapeEntity::VERSION =~ /0\.4\.\d/
          warn 'usage of grape-entity <0.5.0 is deprecated'
          parameters = model.exposures ? model.exposures : model.documentation
        else
          parameters = model.root_exposures.each_with_object({}) do |value, memo|
            memo[value.attribute] = value.send(:options)
          end
        end

        parse_grape_entity_params(parameters)
      end

      private

      def parse_grape_entity_params(params)
        return unless params

        params.each_with_object({}) do |(entity_name, entity_options), memo|
          next unless entity_options.key?(:documentation)
          next if entity_options.fetch(:documentation, {}).fetch(:in, nil).to_s == 'header'

          entity_name = entity_options[:as] if entity_options[:as]
          documentation = entity_options[:documentation]
          model = model_from(entity_options)

          if model
            name = endpoint.nil? ? model.to_s.demodulize : endpoint.send(:expose_params_from_model, model)
            memo[entity_name] = entity_model_type(name, entity_options)
          else
            memo[entity_name] = data_type_from(entity_options)

            if (values = documentation[:values])
              memo[entity_name][:enum] = values if values.is_a?(Array)
            end

            if (default = documentation[:default])
              memo[entity_name][:default] = default
            end

            if documentation[:is_array]
              memo[entity_name] = {
                type: :array,
                items: memo.delete(entity_name)
              }
            end
          end

          if documentation && documentation[:desc]
            memo[entity_name][:description] = documentation[:desc]
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

      def could_it_be_a_model?(value)
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
        documented_type ||= documentation[:documentation][:type]

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

        type[:format] = documentation[:format] if documentation.key?(:format)

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
