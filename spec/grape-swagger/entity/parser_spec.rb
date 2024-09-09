# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../spec/support/shared_contexts/this_api'

describe GrapeSwagger::Entity::Parser do
  context 'this api' do
    include_context 'this api'

    describe '#call' do
      let(:parsed_entity) { described_class.new(ThisApi::Entities::Something, endpoint).call }
      let(:properties) { parsed_entity.first }
      let(:required) { parsed_entity.last }

      context 'when no endpoint is passed' do
        let(:endpoint) { nil }

        it 'parses the model with the correct :using definition' do
          expect(properties[:kind]['$ref']).to eq('#/definitions/Kind')
          expect(properties[:kind2]['$ref']).to eq('#/definitions/Kind')
          expect(properties[:kind3]['$ref']).to eq('#/definitions/Kind')
        end

        it 'merges attributes that have merge: true defined' do
          expect(properties[:merged_attribute]).to be_nil
          expect(properties[:code][:type]).to eq('string')
          expect(properties[:message][:type]).to eq('string')
          expect(properties[:attr][:type]).to eq('string')
        end

        it 'hides hidden attributes' do
          expect(properties).not_to include(:hidden_attr)
        end
      end
    end
  end

  context 'inheritance api' do
    include_context 'inheritance api'

    describe '#call for Parent' do
      let(:parsed_entity) do
        described_class.new(InheritanceApi::Entities::Parent, endpoint).call
      end
      let(:properties) { parsed_entity.first }

      context 'when no endpoint is passed' do
        let(:endpoint) { nil }

        it 'parses the model with discriminator' do
          expect(properties[:type][:documentation]).to eq(is_discriminator: true)
        end
      end
    end

    describe '#call for Child' do
      let(:parsed_entity) do
        described_class.new(InheritanceApi::Entities::Child, endpoint).call
      end
      let(:properties) { parsed_entity }

      context 'when no endpoint is passed' do
        let(:endpoint) { nil }

        it 'parses the model with allOf' do
          expect(properties).to include(:allOf)
          all_of = properties[:allOf]
          child_property = all_of.last.first
          child_required = all_of.last.last
          expect(all_of.first['$ref']).to eq('#/definitions/Parent')
          expect(child_property[:name][:type]).to eq('string')
          expect(child_property[:type][:type]).to eq('string')
          expect(child_property[:type][:enum]).to eq(['Child'])
          expect(child_required).to include(:type)
        end
      end
    end
  end
end
