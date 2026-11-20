# frozen_string_literal: true

describe '#93 non-array entity references with sibling properties' do
  subject(:properties) do
    get '/swagger_doc'
    JSON.parse(last_response.body)['definitions']['RefSiblingsParent']['properties']
  end

  let(:app) do
    Class.new(Grape::API) do
      namespace :ref_siblings do
        class RefSiblingsChild < Grape::Entity
          expose :id, documentation: { type: 'integer' }
        end

        class RefSiblingsParent < Grape::Entity
          expose :plain, using: RefSiblingsChild
          expose :nullable, using: RefSiblingsChild, documentation: { x: { nullable: true } }
          expose :with_example, using: RefSiblingsChild, documentation: { example: { id: 1 } }
          expose :described_nullable,
                 using: RefSiblingsChild,
                 documentation: { desc: 'Described', x: { nullable: true } }
          expose :nullable_list,
                 using: RefSiblingsChild,
                 documentation: { is_array: true, x: { nullable: true } }
        end

        desc 'Get a parent', success: RefSiblingsParent
        get '/parent' do
          present({}, with: RefSiblingsParent)
        end
      end

      add_swagger_documentation format: :json
    end
  end

  it 'keeps a bare $ref when there are no siblings' do
    expect(properties['plain']).to eq('$ref' => '#/definitions/RefSiblingsChild')
  end

  it 'wraps the $ref in allOf to keep an extension' do
    expect(properties['nullable']).to eq(
      'allOf' => [{ '$ref' => '#/definitions/RefSiblingsChild' }],
      'x-nullable' => true
    )
  end

  it 'wraps the $ref in allOf to keep an example' do
    expect(properties['with_example']).to eq(
      'allOf' => [{ '$ref' => '#/definitions/RefSiblingsChild' }],
      'example' => { 'id' => 1 }
    )
  end

  it 'wraps the $ref once when there are several siblings' do
    expect(properties['described_nullable']).to eq(
      'allOf' => [{ '$ref' => '#/definitions/RefSiblingsChild' }],
      'description' => 'Described',
      'x-nullable' => true
    )
  end

  it 'leaves array references unwrapped since items already allow siblings' do
    expect(properties['nullable_list']).to eq(
      'type' => 'array',
      'items' => { '$ref' => '#/definitions/RefSiblingsChild' },
      'x-nullable' => true
    )
  end
end
