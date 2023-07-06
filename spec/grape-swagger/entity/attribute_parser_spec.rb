# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../spec/support/shared_contexts/this_api'

describe GrapeSwagger::Entity::AttributeParser do
  include_context 'this api'

  describe '#call' do
    let(:endpoint) {}

    subject { described_class.new(endpoint).call(entity_options) }

    context 'when the entity is a model' do
      context 'when it is exposed as an array' do
        let(:entity_options) { { using: ThisApi::Entities::Tag, documentation: { is_array: true } } }

        it { is_expected.to include('type' => 'array') }
        it { is_expected.to include('items' => { '$ref' => '#/definitions/Tag' }) }

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

        it { is_expected.to_not include('type') }
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

        context 'when it contains extensions' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', x: { some: 'stuff' } } } }

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
      end

      context 'when it is not exposed as an array' do
        let(:entity_options) { { documentation: { type: 'string', desc: 'Content of something.' } } }

        it { is_expected.to include(type: 'string') }
        it { is_expected.to_not include('$ref') }
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
    end
  end
end
