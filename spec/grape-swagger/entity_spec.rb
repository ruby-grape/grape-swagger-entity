# frozen_string_literal: true

require 'spec_helper'

describe GrapeSwagger::Entity do
  it 'has a version number' do
    expect(GrapeSwagger::Entity::VERSION).not_to be_nil
  end

  it 'parser should be registred' do
    expect(GrapeSwagger.model_parsers.to_a).to include([GrapeSwagger::Entity::Parser, 'Grape::Entity'])
  end
end
