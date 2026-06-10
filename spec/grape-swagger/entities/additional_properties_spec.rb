# frozen_string_literal: true

module AdditionalPropertiesApi
  class ValueEntity < Grape::Entity
    expose :name, documentation: { type: 'string' }
  end

  class WithAdditionalProperties < Grape::Entity
    expose :open_map,
           documentation: { type: Hash, additional_properties: true }
    expose :string_map,
           documentation: { type: Hash, additional_properties: String }
    expose :string_map_via_type_name,
           documentation: { type: 'object', additional_properties: 'string' }
    expose :entity_map,
           documentation: { type: Hash, additional_properties: ValueEntity }
  end
end

describe 'additional_properties' do
  subject(:swagger_doc) do
    get '/swagger_doc'
    JSON.parse(last_response.body)
  end

  let(:app) do
    Class.new(Grape::API) do
      namespace :additional_properties do
        desc 'Get a thing', success: AdditionalPropertiesApi::WithAdditionalProperties
        get '/thing' do
          present({}, with: AdditionalPropertiesApi::WithAdditionalProperties)
        end
      end

      add_swagger_documentation format: :json
    end
  end

  let(:properties) { swagger_doc['definitions']['AdditionalPropertiesApi_WithAdditionalProperties']['properties'] }

  it 'documents boolean additional_properties' do
    expect(properties['open_map']).to eq('type' => 'object', 'additionalProperties' => true)
  end

  it 'documents a primitive Ruby class as a typed schema' do
    expect(properties['string_map']).to eq(
      'type' => 'object',
      'additionalProperties' => { 'type' => 'string' }
    )
  end

  it 'documents a string type name as a typed schema' do
    expect(properties['string_map_via_type_name']).to eq(
      'type' => 'object',
      'additionalProperties' => { 'type' => 'string' }
    )
  end

  it 'documents an entity class as a $ref' do
    expect(properties['entity_map']).to eq(
      'type' => 'object',
      'additionalProperties' => { '$ref' => '#/definitions/AdditionalPropertiesApi_ValueEntity' }
    )
  end

  it 'registers the referenced entity in definitions' do
    expect(swagger_doc['definitions']).to include('AdditionalPropertiesApi_ValueEntity')
    expect(swagger_doc['definitions']['AdditionalPropertiesApi_ValueEntity']).to include(
      'type' => 'object',
      'properties' => { 'name' => { 'type' => 'string' } }
    )
  end
end
