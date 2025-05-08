# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../spec/support/shared_contexts/this_api'

describe GrapeSwagger::Entity::AttributeParser do
  include_context 'this api'

  describe '#call' do
    subject { described_class.new(endpoint).call(entity_options) }

    let(:endpoint) {}

    context 'when the entity is a model' do
      context 'when it is exposed as an array' do
        let(:entity_options) { { using: ThisApi::Entities::Tag, documentation: { is_array: true } } }

        it { is_expected.to include('type' => 'array') }
        it { is_expected.to include('items' => { '$ref' => '#/definitions/Tag' }) }

        context 'when it contains example' do
          let(:entity_options) do
            {
              using: ThisApi::Entities::Tag,
              documentation: {
                is_array: true,
                example: [
                  { name: 'green' },
                  { name: 'blue' }
                ]
              }
            }
          end

          it { is_expected.to include(example: %w[green blue].map { { name: _1 } }) }
        end

        context 'when the entity is implicit Entity' do
          let(:entity_type) do
            Class.new(ThisApi::Entities::Tag) do
              def self.name
                'ThisApi::Tag'
              end

              def self.to_s
                name
              end
            end
          end
          let(:entity_options) { { documentation: { type: entity_type, is_array: true, min_items: 1 } } }

          it { is_expected.to include('type' => 'array') }
          it { is_expected.to include('items' => { '$ref' => '#/definitions/Tag' }) }
        end

        context 'when it contains min_items' do
          let(:entity_options) { { using: ThisApi::Entities::Tag, documentation: { is_array: true, min_items: 1 } } }

          it { is_expected.to include(minItems: 1) }
        end

        context 'when it contains max_items' do
          let(:entity_options) { { using: ThisApi::Entities::Tag, documentation: { is_array: true, max_items: 1 } } }

          it { is_expected.to include(maxItems: 1) }
        end

        context 'when it contains unique_items' do
          let(:entity_options) do
            { using: ThisApi::Entities::Tag, documentation: { is_array: true, unique_items: true } }
          end

          it { is_expected.to include(uniqueItems: true) }
        end
      end

      context 'when it is not exposed as an array' do
        let(:entity_options) do
          { using: ThisApi::Entities::Kind,
            documentation: { type: 'ThisApi::Kind', desc: 'The kind of this something.' } }
        end

        it { is_expected.not_to include('type') }
        it { is_expected.to include('$ref' => '#/definitions/Kind') }
      end
    end

    context 'when the entity is not a model' do
      context 'when it is exposed as a string' do
        let(:entity_options) { { documentation: { type: 'string', desc: 'Colors' } } }

        it { is_expected.to include(type: 'string') }

        context 'when it contains min_length' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', min_length: 1 } } }

          it { is_expected.to include(minLength: 1) }
        end

        context 'when it contains max_length' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', max_length: 1 } } }

          it { is_expected.to include(maxLength: 1) }
        end

        context 'when it contains values array' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', values: %w[red blue] } } }

          it { is_expected.not_to include('minimum') }
          it { is_expected.not_to include('maximum') }
        end

        context 'when it contains values range' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', values: 'a'...'c' } } }

          it { is_expected.not_to include('minimum') }
          it { is_expected.not_to include('maximum') }
        end

        context 'when it contains extensions' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', x: { some: 'stuff' } } } }

          it { is_expected.to include('x-some' => 'stuff') }
        end
      end

      context 'when it is exposed as a number' do
        let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH' } } }

        it { is_expected.to include(type: 'number') }

        context 'when it contains minimum' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', minimum: 2.5 } } }

          it { is_expected.to include(minimum: 2.5) }
        end

        context 'when it contains maximum' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', maximum: 9.1 } } }

          it { is_expected.to include(maximum: 9.1) }
        end

        context 'when it contains values array' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', values: [6.0, 7.0, 8.0] } } }

          it { is_expected.not_to include('minimum') }
          it { is_expected.not_to include('maximum') }
        end

        context 'when it contains values range' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', values: 0.0..14.0 } } }

          it { is_expected.to include(minimum: 0.0, maximum: 14.0) }
        end

        context 'when it contains values range with no minimum' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', values: ..14.0 } } }

          it { is_expected.not_to include('minimum') }
          it { is_expected.to include(maximum: 14.0) }
        end

        context 'when it contains values range with no maximum' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', values: 0.0.. } } }

          it { is_expected.not_to include('maximum') }
          it { is_expected.to include(minimum: 0.0) }
        end

        context 'when it contains extensions' do
          let(:entity_options) { { documentation: { type: 'number', desc: 'Solution pH', x: { some: 'stuff' } } } }

          it { is_expected.to include('x-some' => 'stuff') }
        end
      end

      context 'when it is exposed as an integer' do
        let(:entity_options) { { documentation: { type: 'integer', desc: 'Count' } } }

        it { is_expected.to include(type: 'integer') }

        context 'when it contains minimum' do
          let(:entity_options) { { documentation: { type: 'integer', desc: 'Count', minimum: 2 } } }

          it { is_expected.to include(minimum: 2) }
        end

        context 'when it contains maximum' do
          let(:entity_options) { { documentation: { type: 'integer', desc: 'Count', maximum: 100 } } }

          it { is_expected.to include(maximum: 100) }
        end

        context 'when it contains values array' do
          let(:entity_options) { { documentation: { type: 'integer', desc: 'Count', values: 1..10 } } }

          it { is_expected.not_to include('minimum') }
          it { is_expected.not_to include('maximum') }
        end

        context 'when it contains values range' do
          let(:entity_options) { { documentation: { type: 'integer', desc: 'Count', values: 1..10 } } }

          it { is_expected.to include(minimum: 1, maximum: 10) }
        end

        context 'when it contains extensions' do
          let(:entity_options) { { documentation: { type: 'integer', desc: 'Count', x: { some: 'stuff' } } } }

          it { is_expected.to include('x-some' => 'stuff') }
        end
      end

      context 'when it is exposed as an array' do
        let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true } } }

        it { is_expected.to include(type: :array) }
        it { is_expected.to include(items: { type: 'string' }) }

        context 'when it contains example' do
          let(:entity_options) do
            { documentation: { type: 'string', desc: 'Colors', is_array: true, example: %w[green blue] } }
          end

          it { is_expected.to include(example: %w[green blue]) }
        end

        context 'when it contains min_items' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true, min_items: 1 } } }

          it { is_expected.to include(minItems: 1) }
        end

        context 'when it contains max_items' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true, max_items: 1 } } }

          it { is_expected.to include(maxItems: 1) }
        end

        context 'when it contains unique_items' do
          let(:entity_options) do
            { documentation: { type: 'string', desc: 'Colors', is_array: true, unique_items: true } }
          end

          it { is_expected.to include(uniqueItems: true) }
        end

        context 'when it contains values array' do
          let(:entity_options) do
            { documentation: { type: 'string', desc: 'Colors', is_array: true, values: %w[red blue] } }
          end

          it { is_expected.to eq(type: :array, items: { type: 'string', enum: %w[red blue] }) }
        end
      end

      context 'when it is not exposed as an array' do
        let(:entity_options) { { documentation: { type: 'string', desc: 'Content of something.' } } }

        it { is_expected.to include(type: 'string') }
        it { is_expected.not_to include('$ref') }
      end

      context 'when it is exposed as a Boolean class' do
        let(:entity_options) do
          { documentation: { type: Grape::API::Boolean, example: example_value, default: example_value } }
        end

        context 'when the example value is true' do
          let(:example_value) { true }

          it { is_expected.to include(type: 'boolean', example: example_value, default: example_value) }
        end

        context 'when the example value is false' do
          let(:example_value) { false }

          it { is_expected.to include(type: 'boolean', example: example_value, default: example_value) }
        end
      end

      context 'when it is exposed as a boolean' do
        let(:entity_options) { { documentation: { type: 'boolean', example: example_value, default: example_value } } }

        context 'when the example value is true' do
          let(:example_value) { true }

          it { is_expected.to include(type: 'boolean', example: example_value, default: example_value) }
        end

        context 'when the example value is false' do
          let(:example_value) { false }

          it { is_expected.to include(type: 'boolean', example: example_value, default: example_value) }
        end
      end

      context 'when it is exposed as a hash' do
        let(:entity_options) { { documentation: { type: Hash, example: example_value, default: example_value } } }

        context 'when the example value is true' do
          let(:example_value) { true }

          it { is_expected.to include(type: 'object', example: example_value, default: example_value) }
        end

        context 'when the example value is false' do
          let(:example_value) { false }

          it { is_expected.to include(type: 'object', example: example_value, default: example_value) }
        end
      end
    end
  end
end
