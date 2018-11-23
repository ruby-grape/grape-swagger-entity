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
          let(:entity_options) { { using: ThisApi::Entities::Tag, documentation: { is_array: true, unique_items: true } } }

          it { is_expected.to include(uniqueItems: true) }
        end
      end

      context 'when it is not exposed as an array' do
        let(:entity_options) { { using: ThisApi::Entities::Kind, documentation: { type: 'ThisApi::Kind', desc: 'The kind of this something.' } } }

        it { is_expected.to_not include('type') }
        it { is_expected.to include('$ref' => '#/definitions/Kind') }
      end
    end

    context 'when the entity is not a model' do
      context 'when it is exposed as an array' do
        let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true } } }

        it { is_expected.to include(type: :array) }
        it { is_expected.to include(items: { type: 'string' }) }

        context 'when it contains min_items' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true, min_items: 1 } } }

          it { is_expected.to include(minItems: 1) }
        end

        context 'when it contains max_items' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true, max_items: 1 } } }

          it { is_expected.to include(maxItems: 1) }
        end

        context 'when it contains unique_items' do
          let(:entity_options) { { documentation: { type: 'string', desc: 'Colors', is_array: true, unique_items: true } } }

          it { is_expected.to include(uniqueItems: true) }
        end
      end

      context 'when it is not exposed as an array' do
        let(:entity_options) { { documentation: { type: 'string', desc: 'Content of something.' } } }

        it { is_expected.to include(type: 'string') }
        it { is_expected.to_not include('$ref') }
      end
    end
  end
end
