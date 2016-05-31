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
          parameters = model.exposures ? model.exposures : model.documentation
        elsif ::GrapeEntity::VERSION =~ /0\.5\.\d/
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
          next if entity_options.fetch(:documentation, {}).fetch(:in, nil).to_s == 'header'

          entity_name = entity_options[:as] if entity_options[:as]
          model = entity_options[:using] if entity_options[:using].present?

          if entity_options[:documentation] && could_it_be_a_model?(entity_options[:documentation])
            model ||= entity_options[:documentation][:type]
          end

          if model
            name = endpoint.send(:expose_params_from_model, model)
            memo[entity_name] = entity_model_type(name, entity_options)
          else
            documented_type = entity_options[:type]

            if entity_options[:documentation]
              documented_type ||= entity_options[:documentation][:type]
            end

            data_type = GrapeSwagger::DocMethods::DataType.call(documented_type)

            if GrapeSwagger::DocMethods::DataType.primitive?(data_type)
              data = GrapeSwagger::DocMethods::DataType.mapping(data_type)

              memo[entity_name] = {
                type: data.first,
                format: data.last
              }
            else
              memo[entity_name] = {
                type: data_type
              }
            end

            if entity_options[:values] && entity_options[:values].is_a?(Array)
              memo[entity_name][:enum] = entity_options[:values]
            end

            if entity_options[:documentation] && entity_options[:documentation][:is_array]
              memo[entity_name] = {
                type: :array,
                items: memo.delete(entity_name)
              }
            end
          end

          if entity_options[:documentation] && entity_options[:documentation][:desc]
            memo[entity_name][:description] = entity_options[:documentation][:desc]
          end
        end
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
