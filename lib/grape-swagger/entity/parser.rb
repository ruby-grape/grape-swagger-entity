# frozen_string_literal: true

module GrapeSwagger
  module Entity
    class Parser
      attr_reader :model, :endpoint, :attribute_parser

      def initialize(model, endpoint)
        @model = model
        @endpoint = endpoint
        @attribute_parser = AttributeParser.new(endpoint)
      end

      def call
        parse_grape_entity_params(extract_params(model))
      end

      private

      class Alias
        attr_reader :original, :renamed

        def initialize(original, renamed)
          @original = original
          @renamed = renamed
        end
      end

      def extract_params(exposure)
        GrapeSwagger::Entity::Helper.root_exposure_with_discriminator(exposure).each_with_object({}) do |value, memo|
          if value.for_merge && (value.respond_to?(:entity_class) || value.respond_to?(:using_class_name))
            entity_class = value.respond_to?(:entity_class) ? value.entity_class : value.using_class_name

            extracted_params = extract_params(entity_class)
            memo.merge!(extracted_params)
          else
            opts = value.send(:options)
            opts[:as] ? memo[Alias.new(value.attribute, opts[:as])] = opts : memo[value.attribute] = opts
          end
        end
      end

      def parse_grape_entity_params(params, parent_model = nil)
        return unless params

        required = required_params(params)
        parsed_params = parse_params(params, parent_model)

        handle_discriminator(parsed_params, required)
      end

      def parse_params(params, parent_model)
        params.each_with_object({}) do |(entity_name, entity_options), memo|
          next if skip_param?(entity_options)

          original_entity_name = entity_name.is_a?(Alias) ? entity_name.original : entity_name
          final_entity_name = entity_options.fetch(:as, original_entity_name)

          memo[final_entity_name] = parse_entity_options(entity_options, original_entity_name, parent_model)
          add_documentation_to_memo(memo[final_entity_name], entity_options[:documentation])
        end
      end

      def skip_param?(entity_options)
        documentation_options = entity_options.fetch(:documentation, {})
        in_option = documentation_options.fetch(:in, nil).to_s
        hidden_option = documentation_options.fetch(:hidden, nil)

        in_option == 'header' || hidden_option == true
      end

      def parse_entity_options(entity_options, entity_name, parent_model)
        if entity_options[:nesting]
          parse_nested(entity_name, entity_options, parent_model)
        else
          attribute_parser.call(entity_options)
        end
      end

      def add_documentation_to_memo(memo_entry, documentation)
        return unless documentation

        memo_entry[:readOnly] = documentation[:read_only].to_s == 'true' if documentation[:read_only]
        memo_entry[:description] = documentation[:desc] if documentation[:desc]
      end

      def handle_discriminator(parsed, required)
        discriminator = GrapeSwagger::Entity::Helper.discriminator(model)
        if discriminator
          respond_with_all_of(parsed, required, discriminator)
        else
          [parsed, required]
        end
      end

      def respond_with_all_of(parsed, required, discriminator)
        parent_name = GrapeSwagger::Entity::Helper.model_name(model.superclass, endpoint)

        {
          allOf: [
            {
              '$ref' => "#/definitions/#{parent_name}"
            },
            [
              add_discriminator(parsed, discriminator),
              required.push(discriminator.attribute)
            ]
          ]
        }
      end

      def add_discriminator(parsed, discriminator)
        model_name = GrapeSwagger::Entity::Helper.model_name(model, endpoint)

        parsed.merge(
          discriminator.attribute => {
            type: 'string',
            enum: [model_name]
          }
        )
      end

      def parse_nested(entity_name, entity_options, parent_model = nil)
        nested_entities = if parent_model.nil?
                            model.root_exposures.select_by(entity_name)
                          else
                            parent_model.nested_exposures.select_by(entity_name)
                          end

        params = nested_entities
                 .map(&:nested_exposures)
                 .flatten
                 .each_with_object({}) do |value, memo|
          memo[value.attribute] = value.send(:options)
        end

        properties, required = parse_grape_entity_params(params, nested_entities.last)
        documentation = entity_options[:documentation]
        is_a_collection = documentation.is_a?(Hash) && documentation[:type].to_s.casecmp('array').zero?

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
        params.each_with_object(Set.new) do |(key, options), accum|
          required = if options.fetch(:documentation, {}).key?(:required)
                       options.dig(:documentation, :required)
                     else
                       !options.key?(:if) && !options.key?(:unless) && options[:expose_nil] != false
                     end

          accum.add(options.fetch(:as, key)) if required
        end.to_a
      end

      def with_required(hash, required)
        return hash if required.empty?

        hash[:required] = required
        hash
      end
    end
  end
end
