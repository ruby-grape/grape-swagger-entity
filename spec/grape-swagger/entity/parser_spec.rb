require 'spec_helper'
require_relative '../../../spec/support/shared_contexts/this_api'

describe GrapeSwagger::Entity::Parser do
  include_context 'this api'

  describe '#call' do
    subject(:parsed_entity) { described_class.new(ThisApi::Entities::Something, endpoint).call }

    context 'when no endpoint is passed' do
      let(:endpoint) { nil }

      it 'parses the model with the correct :using definition' do
        expect(parsed_entity[:kind]['$ref']).to eq('#/definitions/Kind')
        expect(parsed_entity[:kind2]['$ref']).to eq('#/definitions/Kind')
        expect(parsed_entity[:kind3]['$ref']).to eq('#/definitions/Kind')
      end

      it 'merges attributes that have merge: true defined' do
        expect(parsed_entity[:merged_attribute]).to be_nil
        expect(parsed_entity[:code][:type]).to eq('string')
        expect(parsed_entity[:message][:type]).to eq('string')
        expect(parsed_entity[:attr][:type]).to eq('string')
      end
    end
  end
end
