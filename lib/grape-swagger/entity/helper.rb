module GrapeSwagger
  module Entity
    class Helper
      def self.model_name(entity_model, endpoint)
        if endpoint.nil?
          entity_model.to_s.demodulize
        else
          endpoint.send(:expose_params_from_model, entity_model)
        end
      end
    end
  end
end