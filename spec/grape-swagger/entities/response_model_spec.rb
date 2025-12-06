# frozen_string_literal: true

require 'spec_helper'

describe 'responseModel' do
  subject do
    get '/swagger_doc/something'
    JSON.parse(last_response.body)
  end

  include_context 'this api'

  def app
    ThisApi::ResponseModelApi
  end

  it 'documents index action' do
    expect(subject['paths']['/something']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => {
          'type' => 'array',
          'items' => { '$ref' => '#/definitions/ThisApi_Entities_Something' }
        }
      }
    )
  end

  it 'documents specified models as show action' do
    expect(subject['paths']['/something/{id}']['get']['responses']).to eq(
      '200' => {
        'description' => 'OK',
        'schema' => { '$ref' => '#/definitions/ThisApi_Entities_Something' }
      },
      '403' => {
        'description' => 'Refused to return something',
        'schema' => { '$ref' => '#/definitions/ThisApi_Entities_Error' }
      }
    )
    expect(subject['definitions'].keys).to include 'ThisApi_Entities_Error'
    expect(subject['definitions']['ThisApi_Entities_Error']).to eq(
      'type' => 'object',
      'description' => 'ThisApi_Entities_Error model',
      'properties' => {
        'code' => { 'type' => 'string', 'description' => 'Error code' },
        'message' => { 'type' => 'string', 'description' => 'Error message' }
      },
      'required' => %w[code message]
    )

    expect(subject['definitions'].keys).to include 'ThisApi_Entities_Something'
    expect(subject['definitions']['ThisApi_Entities_Something']).to eq(
      'type' => 'object',
      'description' => 'ThisApi_Entities_Something model',
      'properties' =>
          { 'text' => { 'type' => 'string', 'description' => 'Content of something.' },
            'colors' => { 'type' => 'array', 'items' => { 'type' => 'string' }, 'description' => 'Colors' },
            'created_at' => { 'type' => 'string', 'format' => 'date-time', 'description' => 'Created at the time.' },
            'kind' => { '$ref' => '#/definitions/ThisApi_Entities_Kind',
                        'description' => 'The kind of this something.' },
            'kind2' => { '$ref' => '#/definitions/ThisApi_Entities_Kind', 'description' => 'Secondary kind.' },
            'kind3' => { '$ref' => '#/definitions/ThisApi_Entities_Kind', 'description' => 'Tertiary kind.' },
            'tags' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/ThisApi_Entities_Tag' },
                        'description' => 'Tags.' },
            'relation' => { '$ref' => '#/definitions/ThisApi_Entities_Relation', 'description' => 'A related model.',
                            'x-other' => 'stuff' },
            'code' => { 'type' => 'string', 'description' => 'Error code' },
            'message' => { 'type' => 'string', 'description' => 'Error message' },
            'attr' => { 'type' => 'string', 'description' => 'Attribute' } },
      'required' => %w[text colors created_at kind kind2 kind3 tags relation attr code message]
    )

    expect(subject['definitions'].keys).to include 'ThisApi_Entities_Kind'
    expect(subject['definitions']['ThisApi_Entities_Kind']).to eq(
      'type' => 'object',
      'properties' => {
        'title' => { 'type' => 'string', 'description' => 'Title of the kind.' },
        'content' => { 'type' => 'string', 'description' => 'Content', 'x-some' => 'stuff' }
      },
      'required' => %w[title content]
    )

    expect(subject['definitions'].keys).to include 'ThisApi_Entities_Relation'
    expect(subject['definitions']['ThisApi_Entities_Relation']).to eq(
      'type' => 'object',
      'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } },
      'required' => %w[name]
    )

    expect(subject['definitions'].keys).to include 'ThisApi_Entities_Tag'
    expect(subject['definitions']['ThisApi_Entities_Tag']).to eq(
      'type' => 'object',
      'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } },
      'required' => %w[name]
    )
  end
end

describe 'building definitions from given entities' do
  subject do
    get '/swagger_doc'
    JSON.parse(last_response.body)['definitions']
  end

  before :all do
    module TheseApi
      module Entities
        class Values < Grape::Entity
          expose :guid, documentation: { desc: 'Some values', values: %w[a b c], default: 'c' }
          expose :uuid, documentation: { desc: 'customer uuid', type: String, format: 'own',
                                         example: 'e3008fba-d53d-4bcc-a6ae-adc56dff8020' }
          expose :color, documentation: { desc: 'Color', type: String, values: -> { %w[red blue] } }
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
            expose :attr, as: :some2, documentation: { desc: 'Required some 2' }
            expose :some3, documentation: { required: false, desc: 'Optional some 3' }
            expose :some4, if: -> { true }, documentation: { desc: 'Optional some 4' }
            expose :some5, unless: -> { true }, documentation: { desc: 'Optional some 5' }
            expose :some6, expose_nil: false, documentation: { desc: 'Optional some 6' }
          end

          expose :nested_array, documentation: { type: 'Array', desc: 'Nested array' } do
            expose :id, documentation: { type: 'Integer', desc: 'Collection element id' }
            expose :name, documentation: { type: 'String', desc: 'Collection element name' }
          end
        end

        class NestedChild < Nested
          expose :nested, documentation: { type: Hash, desc: 'Nested entity' } do
            expose :some3, documentation: { type: 'String', desc: 'Nested some 3' }
          end

          expose :nested_with_alias, as: :aliased do
            expose :some2, documentation: { type: 'String', desc: 'Alias some 2' }
          end

          expose :deep_nested, documentation: { type: 'Object', desc: 'Deep nested entity' } do
            expose :level_1, documentation: { type: 'Object', desc: 'More deepest nested entity' } do
              expose :level_2, documentation: { type: 'String', desc: 'Level 2' } do
                expose :level_3, documentation: { type: 'String', desc: 'Level 3' }
              end
            end
          end

          expose :nested_array, documentation: { type: 'Array', desc: 'Nested array' } do
            expose :category, documentation: { type: 'String', desc: 'Collection element category' }
          end
        end

        class Polymorphic < Grape::Entity
          expose :obj, as: :kind, if: lambda { |instance, _|
                                        instance.type == 'kind'
                                      }, using: Kind, documentation: { desc: 'Polymorphic Kind' }
          expose :obj, as: :values, if: lambda { |instance, _|
                                          instance.type == 'values'
                                        }, using: Values, documentation: { desc: 'Polymorphic Values' }
          expose :not_using_obj, as: :str, if: lambda { |instance, _|
                                                 instance.instance_of?(String)
                                               }, documentation: { desc: 'Polymorphic String' }
          expose :not_using_obj, as: :num, if: lambda { |instance, _|
                                                 instance.instance_of?(Number)
                                               }, documentation: { desc: 'Polymorphic Number', type: 'Integer' }
        end

        class TagType < CustomType
          def tags
            %w[Cyan Magenta Yellow Key]
          end
        end

        class MixedType < Grape::Entity
          expose :tags, documentation: { type: TagType, desc: 'Tags', is_array: true }
        end

        class SomeEntity < Grape::Entity
          expose :text, documentation: { type: 'string', desc: 'Content of something.' }
          expose :kind, using: Kind, documentation: { type: 'TheseApi_Kind', desc: 'The kind of this something.' }
          expose :kind2, using: Kind, documentation: { desc: 'Secondary kind.' }
          expose :kind3, using: TheseApi::Entities::Kind, documentation: { desc: 'Tertiary kind.' }
          expose :tags, using: TheseApi::Entities::Tag, documentation: { desc: 'Tags.', is_array: true }
          expose :relation, using: TheseApi::Entities::Relation,
                            documentation: { type: 'TheseApi_Relation', desc: 'A related model.' }
          expose :values, using: TheseApi::Entities::Values, documentation: { desc: 'Tertiary kind.' }
          expose :nested, using: TheseApi::Entities::Nested, documentation: { desc: 'Nested object.' }
          expose :nested_child, using: TheseApi::Entities::NestedChild, documentation: { desc: 'Nested child object.' }
          expose :polymorphic, using: TheseApi::Entities::Polymorphic, documentation: { desc: 'A polymorphic model.' }
          expose :mixed, using: TheseApi::Entities::MixedType, documentation: { desc: 'A model with mix of types.' }
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

  it 'prefers entity over other `using` values' do
    expect(subject['TheseApi_Entities_Values']).to eql(
      'type' => 'object',
      'properties' => {
        'guid' => { 'type' => 'string', 'enum' => %w[a b c], 'default' => 'c', 'description' => 'Some values' },
        'uuid' => { 'type' => 'string', 'format' => 'own', 'description' => 'customer uuid',
                    'example' => 'e3008fba-d53d-4bcc-a6ae-adc56dff8020' },
        'color' => { 'type' => 'string', 'enum' => %w[red blue], 'description' => 'Color' }
      },
      'required' => %w[guid uuid color]
    )
    expect(subject['TheseApi_Entities_Kind']).to eql(
      'type' => 'object',
      'properties' => {
        'id' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'id of the kind.', 'enum' => [1, 2],
                  'readOnly' => true },
        'title' => { 'type' => 'string', 'description' => 'Title of the kind.', 'readOnly' => false },
        'type' => { 'type' => 'string', 'description' => 'Type of the kind.', 'readOnly' => true }
      },
      'required' => %w[id title type]
    )
    expect(subject['TheseApi_Entities_Tag']).to eql(
      'type' => 'object',
      'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name', 'example' => 'random_tag' } },
      'required' => %w[name]
    )
    expect(subject['TheseApi_Entities_Relation']).to eql(
      'type' => 'object',
      'properties' => { 'name' => { 'type' => 'string', 'description' => 'Name' } },
      'required' => %w[name]
    )
    expect(subject['TheseApi_Entities_Nested']).to eq(
      'type' => 'object',
      'properties' => {
        'nested' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Nested some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Nested some 2' }
          },
          'description' => 'Nested entity',
          'required' => %w[some1 some2]
        },
        'aliased' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Alias some 1' }
          },
          'required' => %w[some1]
        },
        'deep_nested' => {
          'type' => 'object',
          'properties' => {
            'level_1' => {
              'type' => 'object',
              'properties' => {
                'level_2' => { 'type' => 'string', 'description' => 'Level 2' }
              },
              'description' => 'More deepest nested entity',
              'required' => %w[level_2]
            }
          },
          'description' => 'Deep nested entity',
          'required' => %w[level_1]
        },
        'nested_required' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Required some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Required some 2' },
            'some3' => { 'type' => 'string', 'description' => 'Optional some 3' },
            'some4' => { 'type' => 'string', 'description' => 'Optional some 4' },
            'some5' => { 'type' => 'string', 'description' => 'Optional some 5' },
            'some6' => { 'type' => 'string', 'description' => 'Optional some 6' }
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
            },
            'required' => %w[id name]
          },
          'description' => 'Nested array'
        }
      },
      'required' => %w[nested aliased deep_nested nested_required nested_array]
    )
    expect(subject['TheseApi_Entities_NestedChild']).to eq(
      'type' => 'object',
      'properties' => {
        'nested' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Nested some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Nested some 2' },
            'some3' => { 'type' => 'string', 'description' => 'Nested some 3' }
          },
          'description' => 'Nested entity',
          'required' => %w[some1 some2 some3]
        },
        'aliased' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Alias some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Alias some 2' }
          },
          'required' => %w[some1 some2]
        },
        'deep_nested' => {
          'type' => 'object',
          'properties' => {
            'level_1' => {
              'type' => 'object',
              'properties' => {
                'level_2' => {
                  'type' => 'object',
                  'properties' => {
                    'level_3' => {
                      'type' => 'string',
                      'description' => 'Level 3'
                    }
                  },
                  'description' => 'Level 2',
                  'required' => %w[level_3]
                }
              },
              'description' => 'More deepest nested entity',
              'required' => %w[level_2]
            }
          },
          'description' => 'Deep nested entity',
          'required' => %w[level_1]
        },
        'nested_required' => {
          'type' => 'object',
          'properties' => {
            'some1' => { 'type' => 'string', 'description' => 'Required some 1' },
            'some2' => { 'type' => 'string', 'description' => 'Required some 2' },
            'some3' => { 'type' => 'string', 'description' => 'Optional some 3' },
            'some4' => { 'type' => 'string', 'description' => 'Optional some 4' },
            'some5' => { 'type' => 'string', 'description' => 'Optional some 5' },
            'some6' => { 'type' => 'string', 'description' => 'Optional some 6' }
          },
          'required' => %w[some1 some2]
        },
        'nested_array' => {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'properties' => {
              'id' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'Collection element id' },
              'name' => { 'type' => 'string', 'description' => 'Collection element name' },
              'category' => { 'type' => 'string', 'description' => 'Collection element category' }
            },
            'required' => %w[id name category]
          },
          'description' => 'Nested array'
        }
      },
      'required' => %w[nested aliased deep_nested nested_required nested_array]
    )
    expect(subject['TheseApi_Entities_Polymorphic']).to eql(
      'type' => 'object',
      'properties' => {
        'kind' => { '$ref' => '#/definitions/TheseApi_Entities_Kind', 'description' => 'Polymorphic Kind' },
        'values' => { '$ref' => '#/definitions/TheseApi_Entities_Values', 'description' => 'Polymorphic Values' },
        'str' => { 'type' => 'string', 'description' => 'Polymorphic String' },
        'num' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'Polymorphic Number' }
      }
    )

    expect(subject['TheseApi_Entities_MixedType']).to eql(
      'type' => 'object',
      'properties' => {
        'tags' => {
          'description' => 'Tags',
          'items' => { '$ref' => '#/definitions/TheseApi_Entities_TagType' },
          'type' => 'array'
        }
      },
      'required' => %w[tags]
    )

    expect(subject['TheseApi_Entities_SomeEntity']).to eql(
      'type' => 'object',
      'properties' => {
        'text' => { 'type' => 'string', 'description' => 'Content of something.' },
        'kind' => { '$ref' => '#/definitions/TheseApi_Entities_Kind', 'description' => 'The kind of this something.' },
        'kind2' => { '$ref' => '#/definitions/TheseApi_Entities_Kind', 'description' => 'Secondary kind.' },
        'kind3' => { '$ref' => '#/definitions/TheseApi_Entities_Kind', 'description' => 'Tertiary kind.' },
        'tags' => { 'type' => 'array', 'items' => { '$ref' => '#/definitions/TheseApi_Entities_Tag' },
                    'description' => 'Tags.' },
        'relation' => { '$ref' => '#/definitions/TheseApi_Entities_Relation', 'description' => 'A related model.' },
        'values' => { '$ref' => '#/definitions/TheseApi_Entities_Values', 'description' => 'Tertiary kind.' },
        'nested' => { '$ref' => '#/definitions/TheseApi_Entities_Nested', 'description' => 'Nested object.' },
        'nested_child' => { '$ref' => '#/definitions/TheseApi_Entities_NestedChild',
                            'description' => 'Nested child object.' },
        'code' => { 'type' => 'string', 'description' => 'Error code' },
        'message' => { 'type' => 'string', 'description' => 'Error message' },
        'polymorphic' => { '$ref' => '#/definitions/TheseApi_Entities_Polymorphic',
                           'description' => 'A polymorphic model.' },
        'mixed' => {
          '$ref' => '#/definitions/TheseApi_Entities_MixedType',
          'description' => 'A model with mix of types.'
        },
        'attr' => { 'type' => 'string', 'description' => 'Attribute' }
      },
      'required' => %w[text kind kind2 kind3 tags relation values nested nested_child
                       polymorphic mixed attr code message],
      'description' => 'TheseApi_Entities_SomeEntity model'
    )
  end
end
