shared_context 'this api' do
  before :all do
    module ThisApi
      module Entities
        class Kind < Grape::Entity
          expose :title, documentation: { type: 'string', desc: 'Title of the kind.' }
          expose :content, documentation: { type: 'string', desc: 'Content', x: { some: 'stuff' } }
        end

        class Relation < Grape::Entity
          expose :name, documentation: { type: 'string', desc: 'Name' }
        end
        class Tag < Grape::Entity
          expose :name, documentation: { type: 'string', desc: 'Name' }
        end
        class Error < Grape::Entity
          expose :code, documentation: { type: 'string', desc: 'Error code' }
          expose :message, documentation: { type: 'string', desc: 'Error message' }
        end

        class Nested < Grape::Entity
          expose :attr, documentation: { required: true, type: 'string', desc: 'Attribute' }
          expose :nested_attrs, merge: true, using: ThisApi::Entities::Error
        end

        class Something < Grape::Entity
          expose :text, documentation: { type: 'string', desc: 'Content of something.' }
          expose :colors, documentation: { type: 'string', desc: 'Colors', is_array: true }
          expose :hidden_attr, documentation: { type: 'string', desc: 'Hidden', hidden: true }
          expose :kind, using: Kind, documentation: { type: 'ThisApi::Kind', desc: 'The kind of this something.' }
          expose :kind2, using: Kind, documentation: { desc: 'Secondary kind.' }
          expose :kind3, using: ThisApi::Entities::Kind, documentation: { desc: 'Tertiary kind.' }
          expose :tags, using: ThisApi::Entities::Tag, documentation: { desc: 'Tags.', is_array: true }
          expose :relation, using: ThisApi::Entities::Relation, documentation: { type: 'ThisApi::Relation', desc: 'A related model.' }
          expose :merged_attribute, using: ThisApi::Entities::Nested, merge: true
        end
      end

      class ResponseModelApi < Grape::API
        format :json
        desc 'This returns something',
             is_array: true,
             http_codes: [{ code: 200, message: 'OK', model: Entities::Something }]
        get '/something' do
          something = OpenStruct.new text: 'something'
          present something, with: Entities::Something
        end

        # something like an index action
        desc 'This returns something or an error',
             entity: Entities::Something,
             http_codes: [
               { code: 200, message: 'OK', model: Entities::Something },
               { code: 403, message: 'Refused to return something', model: Entities::Error }
             ]
        params do
          optional :id, type: Integer
        end
        get '/something/:id' do
          if params[:id] == 1
            something = OpenStruct.new text: 'something'
            present something, with: Entities::Something
          else
            error = OpenStruct.new code: 'some_error', message: 'Some error'
            present error, with: Entities::Error
          end
        end

        add_swagger_documentation
      end
    end
  end
end
