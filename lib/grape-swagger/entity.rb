# frozen_string_literal: true

require 'grape-swagger'
require 'grape-entity'

require 'grape-swagger/entity/version'
require 'grape-swagger/entity/helper'
require 'grape-swagger/entity/attribute_parser'
require 'grape-swagger/entity/parser'

module GrapeSwagger
  module Entity
  end
end

GrapeSwagger.model_parsers.register(GrapeSwagger::Entity::Parser, Grape::Entity)
