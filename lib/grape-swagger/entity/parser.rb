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
        return if params.nil?

        params.each_with_object({}) do |x, memo|
          next if x[1].fetch(:documentation, {}).fetch(:in, nil).to_s == 'header'
          x[0] = x.last[:as] if x.last[:as]

          model = x.last[:using] if x.last[:using].present?
          model ||= x.last[:documentation][:type] if x.last[:documentation] && could_it_be_a_model?(x.last[:documentation])

          if model
            name = endpoint.send(:expose_params_from_model, model)
            memo[x.first] = if x.last[:documentation] && x.last[:documentation][:is_array]
                              { 'type' => 'array', 'items' => { '$ref' => "#/definitions/#{name}" } }
                            else
                              { '$ref' => "#/definitions/#{name}" }
                            end
          else
            documented_type = x.last[:type]
            documented_type ||= x.last[:documentation][:type] if x.last[:documentation]
            data_type = GrapeSwagger::DocMethods::DataType.call(documented_type)

            if GrapeSwagger::DocMethods::DataType.primitive?(data_type)
              data = GrapeSwagger::DocMethods::DataType.mapping(data_type)
              memo[x.first] = { type: data.first, format: data.last }
            else
              memo[x.first] = { type: data_type }
            end

            memo[x.first][:enum] = x.last[:values] if x.last[:values] && x.last[:values].is_a?(Array)
          end
          memo[x.first][:description] = x.last[:documentation][:desc] if x.last[:documentation] && x.last[:documentation][:desc]
        end
      end

      def could_it_be_a_model?(value)
        (
          value[:type].to_s.include?('Entity') || value[:type].to_s.include?('Entities')
        ) || (
          value[:type] &&
          value[:type].is_a?(Class) &&
          !GrapeSwagger::DocMethods::DataType.primitive?(value[:type].name.downcase) &&
          !value[:type] == Array
        )
      end
    end
  end
end
