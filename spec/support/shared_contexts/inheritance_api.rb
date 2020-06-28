shared_context 'inheritance api' do
  before :all do
    module InheritanceApi
      module Entities
        class Parent < Grape::Entity
          expose :type, documentation: { type: 'string', is_discriminator: true, required: true }
          expose :id, documentation: { type: 'integer' }
        end

        class Child < Parent
          expose :name, documentation: { type: 'string', desc: 'Name' }
        end
      end
    end
  end
end
