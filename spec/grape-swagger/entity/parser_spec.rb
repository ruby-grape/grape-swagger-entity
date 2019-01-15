require 'spec_helper'
require_relative '../../../spec/support/shared_contexts/this_api'

describe GrapeSwagger::Entity::Parser do
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
        expect(properties).to_not include(:hidden_attr)
      end
    end
  end
end
