require 'spec_helper'

describe 'responseModel' do
  include_context 'this api'

  def app
    ThisApi::ResponseModelApi
  end

  subject do
    get '/swagger_doc/something'
    JSON.parse(last_response.body)
  end

  it 'documents index action' do
    expect(subject['paths']['/something']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => {
          'type' => 'array',
          'items' => { '$ref' => '#/definitions/Something' }
        }
      }
    )
  end

  it 'should document specified models as show action' do
    expect(subject['paths']['/something/{id}']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => { '$ref' => '#/definitions/Something' }
      },
      '403' => {
        'description' => 'Refused to return something',
        'schema' => { '$ref' => '#/definitions/Error' }
      }
    )
    expect(subject['definitions'].keys).to include 'Error'
    expect(subject['definitions']['Error']).to eq(
      'type' => 'object',
      'description' => 'This returns something or an error',
      'properties' => {
        'code' => { 'type' => 'string', 'description' => 'Error code' },
        'message' => { 'type' => 'string', 'description' => 'Error message' }
      }
    )

    expect(subject['definitions'].keys).to include 'Something'
    expect(subject['definitions']['Something']).to eq(
      'type' => 'object',
      'description' => 'This returns something',
      'properties' =>
          { 'text' => { 'type' => 'string', 'description' => 'Content of something.' },
            'colors' => { 'type' => 'array', 'items' => { 'type' => 'string' }, 'description' => 'Colors' },
            'kind' => { '$ref' => '#/definitions/Kind', 'description' => 'The kind of this something.' },
            'kind2' => { '$ref' => '#/definitions/Kind', 'description' => 'Secondary kind.' },
            'kind3' => { '$ref' => '#/definitions/Kind', 'description' => 'Tertiary kind.' },
            'tags' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/Tag' }, 'description' => 'Tags.' },
            'relation' => { '$ref' => '#/definitions/Relation', 'description' => 'A related model.' },
            'code' => { 'type' => 'string', 'description' => 'Error code' },
            'message' => { 'type' => 'string', 'description' => 'Error message' },
            'attr' => { 'type' => 'string', 'description' => 'Attribute' } }
    )

    expect(subject['definitions'].keys).to include 'Kind'
    expect(subject['definitions']['Kind']).to eq(
      'type' => 'object', 'properties' => { 'title' => { 'type' => 'string', 'description' => 'Title of the kind.' } }
    )

    expect(subject['definitions'].keys).to include 'Relation'
    expect(subject['definitions']['Relation']).to eq(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } }
    )

    expect(subject['definitions'].keys).to include 'Tag'
    expect(subject['definitions']['Tag']).to eq(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } }
    )
  end
end

describe 'building definitions from given entities' do
  before :all do
    module TheseApi
      module Entities
        class Values < Grape::Entity
          expose :guid, documentation: { desc: 'Some values', values: %w[a b c], default: 'c' }
          expose :uuid, documentation: { desc: 'customer uuid', type: String, format: 'own',
                                         example: 'e3008fba-d53d-4bcc-a6ae-adc56dff8020' }
        end

        class Kind < Grape::Entity
          expose :id, documentation: { type: Integer, desc: 'id of the kind.', values: [1, 2], read_only: true }
          expose :title, documentation: { type: String, desc: 'Title of the kind.', read_only: 'false' }
          expose :type, documentation: { type: String, desc: 'Type of the kind.', read_only: 'true' }
        end

        class Relation < Grape::Entity
          expose :name, documentation: { type: String, desc: 'Name' }
        end
        class Tag < Grape::Entity
          expose :name, documentation: { type: 'string', desc: 'Name',
                                         example: -> { 'random_tag' } }
        end

        class Nested < Grape::Entity
          expose :nested, documentation: { type: Hash, desc: 'Nested entity' } do
            expose :some1, documentation: { type: 'String', desc: 'Nested some 1' }
            expose :some2, documentation: { type: 'String', desc: 'Nested some 2' }
          end
          expose :nested_with_alias, as: :aliased do
            expose :some1, documentation: { type: 'String', desc: 'Alias some 1' }
          end
          expose :deep_nested, documentation: { type: 'Object', desc: 'Deep nested entity' } do
            expose :level_1, documentation: { type: 'Object', desc: 'More deepest nested entity' } do
              expose :level_2, documentation: { type: 'String', desc: 'Level 2' }
            end
          end
          expose :nested_required do
            expose :some1, documentation: { required: true, desc: 'Required some 1' }
            expose :attr, as: :some2, documentation: { required: true, desc: 'Required some 2' }
            expose :some3, documentation: { desc: 'Optional some 3' }
          end

          expose :nested_array, documentation: { type: 'Array', desc: 'Nested array' } do
            expose :id, documentation: { type: 'Integer', desc: 'Collection element id' }
            expose :name, documentation: { type: 'String', desc: 'Collection element name' }
          end
        end

        class SomeEntity < Grape::Entity
          expose :text, documentation: { type: 'string', desc: 'Content of something.' }
          expose :kind, using: Kind, documentation: { type: 'TheseApi::Kind', desc: 'The kind of this something.' }
          expose :kind2, using: Kind, documentation: { desc: 'Secondary kind.' }
          expose :kind3, using: TheseApi::Entities::Kind, documentation: { desc: 'Tertiary kind.' }
          expose :tags, using: TheseApi::Entities::Tag, documentation: { desc: 'Tags.', is_array: true }
          expose :relation, using: TheseApi::Entities::Relation, documentation: { type: 'TheseApi::Relation', desc: 'A related model.' }
          expose :values, using: TheseApi::Entities::Values, documentation: { desc: 'Tertiary kind.' }
          expose :nested, using: TheseApi::Entities::Nested, documentation: { desc: 'Nested object.' }
          expose :merged_attribute, using: ThisApi::Entities::Nested, merge: true
        end
      end

      class ResponseEntityApi < Grape::API
        format :json
        desc 'This returns something',
             is_array: true,
             entity: Entities::SomeEntity
        get '/some_entity' do
          something = OpenStruct.new text: 'something'
          present something, with: Entities::SomeEntity
        end

        add_swagger_documentation
      end
    end
  end

  def app
    TheseApi::ResponseEntityApi
  end

  subject do
    get '/swagger_doc'
    JSON.parse(last_response.body)['definitions']
  end

  it 'prefers entity over other `using` values' do
    expect(subject['Values']).to eql(
      'type' => 'object',
      'properties' => {
        'guid' => { 'type' => 'string', 'enum' => %w[a b c], 'default' => 'c', 'description' => 'Some values' },
        'uuid' => { 'type' => 'string', 'format' => 'own', 'description' => 'customer uuid', 'example' => 'e3008fba-d53d-4bcc-a6ae-adc56dff8020' }
      }
    )
    expect(subject['Kind']).to eql(
      'type' => 'object',
      'properties' => {
        'id' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'id of the kind.', 'enum' => [1, 2], 'readOnly' => true },
        'title' => { 'type' => 'string', 'description' => 'Title of the kind.', 'readOnly' => false },
        'type' => { 'type' => 'string', 'description' => 'Type of the kind.', 'readOnly' => true }
      }
    )
    expect(subject['Tag']).to eql(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name', 'example' => 'random_tag' } }
    )
    expect(subject['Relation']).to eql(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } }
    )
    expect(subject['Nested']).to eq(
      'properties' => {
        'nested' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Nested some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Nested some 2' }
          },
          'description' => 'Nested entity'
        },
        'aliased' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Alias some 1' }
          }
        },
        'deep_nested' => {
          'type' => 'object',
          'properties' => {
            'level_1' => {
              'type' => 'object',
              'properties' => {
                'level_2' => { 'type' => 'string', 'description' => 'Level 2' }
              },
              'description' => 'More deepest nested entity'
            }
          },
          'description' => 'Deep nested entity'
        },
        'nested_required' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Required some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Required some 2' },
            'some3' => { 'type' => 'string', 'description' => 'Optional some 3' }
          },
          'required' => %w[some1 some2]
        },
        'nested_array' => {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'properties' => {
              'id' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'Collection element id' },
              'name' => { 'type' => 'string', 'description' => 'Collection element name' }
            }
          },
          'description' => 'Nested array'
        }
      },
      'type' => 'object'
    )

    expect(subject['SomeEntity']).to eql(
      'type' => 'object',
      'properties' => {
        'text' => { 'type' => 'string', 'description' => 'Content of something.' },
        'kind' => { '$ref' => '#/definitions/Kind', 'description' => 'The kind of this something.' },
        'kind2' => { '$ref' => '#/definitions/Kind', 'description' => 'Secondary kind.' },
        'kind3' => { '$ref' => '#/definitions/Kind', 'description' => 'Tertiary kind.' },
        'tags' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/Tag' }, 'description' => 'Tags.' },
        'relation' => { '$ref' => '#/definitions/Relation', 'description' => 'A related model.' },
        'values' => { '$ref' => '#/definitions/Values', 'description' => 'Tertiary kind.' },
        'nested' => { '$ref' => '#/definitions/Nested', 'description' => 'Nested object.' },
        'code' => { 'type' => 'string', 'description' => 'Error code' },
        'message' => { 'type' => 'string', 'description' => 'Error message' },
        'attr' => { 'type' => 'string', 'description' => 'Attribute' }
      },
      'description' => 'This returns something'
    )
  end
end
