module GrapeSwagger
  module Entity
    class Parser
      attr_reader :model
      attr_reader :endpoint
      attr_reader :attribute_parser

      def initialize(model, endpoint)
        @model = model
        @endpoint = endpoint
        @attribute_parser = AttributeParser.new(endpoint)
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

          memo[entity_name] = if entity_options[:nesting]
                                parse_nested(entity_name, entity_options, parent_model)
                              else
                                attribute_parser.call(entity_options)
                              end

          if documentation
            memo[entity_name][:read_only] = documentation[:read_only].to_s == 'true' if documentation[:read_only]
            memo[entity_name][:description] = documentation[:desc] if documentation[:desc]
          end
        end
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

        required = required_params(params)

        properties = parse_grape_entity_params(params, nested_entity)
        is_a_collection = entity_options[:documentation].is_a?(Hash) &&
                          entity_options[:documentation][:type].to_s.casecmp('array').zero?

        if is_a_collection
          {
            type: :array,
            items: with_required({
              type: :object,
              properties: properties
            }, required)
          }
        else
          with_required({
            type: :object,
            properties: properties
          }, required)
        end
      end

      def required_params(params)
        params.select { |_, options| options.dig(:documentation, :required) }.map(&:first)
      end

      def with_required(hash, required)
        return hash if required.empty?
        hash[:required] = required
        hash
      end
    end
  end
end
