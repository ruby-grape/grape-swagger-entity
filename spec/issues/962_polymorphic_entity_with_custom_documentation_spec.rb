# frozen_string_literal: true

describe '#962 empty entity with custom documentation type' do
  context "when entity has no properties" do
    let(:app) do
      Class.new(Grape::API) do
        namespace :issue962 do
          class Foo < Grape::Entity
          end

          class Report < Grape::Entity
            expose :foo,
              as: :bar,
              using: Foo,
              documentation: {
                type: 'Array[object]',
                desc: 'The bar in your report',
                example: {
                  'id' => 'string',
                  'status' => 'string',
                }
              }
          end

          desc 'Get a report', success: Report
          get '/' do
            present({ foo: [] }, with: Report)
          end
        end

        add_swagger_documentation format: :json
      end
    end

    subject(:swagger_doc) do
      get '/swagger_doc'
      JSON.parse(last_response.body)
    end

    specify do
      expect(swagger_doc['definitions']['Report']['properties']['bar']).to eql({
        'type' => 'array',
        'description' => 'The bar in your report',
        'items' => {
          '$ref' => '#/definitions/Foo'
        },
        'example' => {
          'id' => 'string',
          'status' => 'string'
        }
      })
    end

    specify do
      expect(swagger_doc['definitions']['Foo']).to eql({
        'type' => 'object',
        'properties' => {},
      })
    end
  end

  context "when entity has only hidden properties" do
    let(:app) do
      Class.new(Grape::API) do
        namespace :issue962 do
          class Foo < Grape::Entity
            expose :required_prop, documentation: { hidden: true }
            expose :optional_prop, documentation: { hidden: true }, if: ->() { true }
          end

          class Report < Grape::Entity
            expose :foo,
              as: :bar,
              using: Foo,
              documentation: {
                type: 'Array[object]',
                desc: 'The bar in your report',
                example: {
                  'id' => 'string',
                  'status' => 'string',
                }
              }
          end

          desc 'Get a report', success: Report
          get '/' do
            present({ foo: [] }, with: Report)
          end
        end

        add_swagger_documentation format: :json
      end
    end

    subject(:swagger_doc) do
      get '/swagger_doc'
      JSON.parse(last_response.body)
    end

    specify do
      expect(swagger_doc['definitions']['Report']['properties']['bar']).to eql({
        'type' => 'array',
        'description' => 'The bar in your report',
        'items' => {
          '$ref' => '#/definitions/Foo'
        },
        'example' => {
          'id' => 'string',
          'status' => 'string'
        }
      })
    end

    it "hides optional properties only" do
      expect(swagger_doc['definitions']['Foo']).to eql({
        'type' => 'object',
        'properties' => {},
        'required' => ['required_prop'],
      })
    end
  end
end
