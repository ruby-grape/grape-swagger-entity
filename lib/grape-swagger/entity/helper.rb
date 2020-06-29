# frozen_string_literal: true

module GrapeSwagger
  module Entity
    # Helper methods for DRY
    class Helper
      class << self
        def model_name(entity_model, endpoint)
          if endpoint.nil?
            entity_model.to_s.demodulize
          else
            endpoint.send(:expose_params_from_model, entity_model)
          end
        end

        def discriminator(entity_model)
          entity_model.superclass.root_exposures.detect do |value|
            value.documentation&.dig(:is_discriminator)
          end
        end

        def root_exposures_without_parent(entity_model)
          entity_model.root_exposures.select do |value|
            entity_model.superclass.root_exposures.find_by(value.attribute).nil?
          end
        end

        def root_exposure_with_discriminator(entity_model)
          if discriminator(entity_model)
            root_exposures_without_parent(entity_model)
          else
            entity_model.root_exposures
          end
        end
      end
    end
  end
end
