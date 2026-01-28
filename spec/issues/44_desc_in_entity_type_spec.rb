# frozen_string_literal: true

describe '#44 desc not rendered for non-array entity references' do
  subject(:swagger_doc) do
    get '/swagger_doc'
    JSON.parse(last_response.body)
  end

  let(:app) do
    Class.new(Grape::API) do
      namespace :issue44 do
        class Address < Grape::Entity
          expose :street, documentation: { type: 'string', desc: 'Street' }
        end

        class Client < Grape::Entity
          expose :name, documentation: { type: 'string', desc: 'Name' }
          expose :address,
                 using: Address,
                 documentation: { type: 'Address', desc: 'Client address', is_array: false }
          expose :billing_address,
                 using: Address,
                 documentation: { type: 'Address', read_only: true }
        end

        class ClientWithArrayAddress < Grape::Entity
          expose :name, documentation: { type: 'string', desc: 'Name' }
          expose :addresses,
                 using: Address,
                 documentation: { type: 'Address', desc: 'Client addresses', is_array: true }
        end

        desc 'Get a client', success: Client
        get '/client' do
          present({ name: 'John', address: { street: '123 Main St' } }, with: Client)
        end

        desc 'Get a client with addresses', success: ClientWithArrayAddress
        get '/client_with_addresses' do
          present({ name: 'John', addresses: [{ street: '123 Main St' }] }, with: ClientWithArrayAddress)
        end
      end

      add_swagger_documentation format: :json
    end
  end

  describe 'non-array entity reference' do
    subject(:address_property) { swagger_doc['definitions']['Client']['properties']['address'] }

    it 'includes description using allOf wrapper for OpenAPI compatibility' do
      # In OpenAPI/Swagger, $ref cannot have sibling properties.
      # To add description to a $ref, it must be wrapped in allOf.
      # See: https://swagger.io/docs/specification/using-ref/#syntax
      expect(address_property).to eq({
        'allOf' => [{ '$ref' => '#/definitions/Address' }],
        'description' => 'Client address'
      })
    end
  end

  describe 'non-array entity reference with readOnly' do
    subject(:billing_property) { swagger_doc['definitions']['Client']['properties']['billing_address'] }

    it 'includes readOnly using allOf wrapper for OpenAPI compatibility' do
      # readOnly is also a sibling property that needs allOf wrapping
      expect(billing_property).to eq({
        'allOf' => [{ '$ref' => '#/definitions/Address' }],
        'readOnly' => true
      })
    end
  end

  describe 'array entity reference' do
    subject(:addresses_property) { swagger_doc['definitions']['ClientWithArrayAddress']['properties']['addresses'] }

    it 'includes description directly since array wrapper allows siblings' do
      # For arrays, the description can be a sibling to 'type' and 'items'
      expect(addresses_property).to eq({
        'type' => 'array',
        'items' => { '$ref' => '#/definitions/Address' },
        'description' => 'Client addresses'
      })
    end
  end
end
