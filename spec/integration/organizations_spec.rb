require 'swagger_helper'

describe 'Organizations API' do
  path '/organizations' do
    get 'List Organizations' do
      tags 'Organizations'
      produces 'application/json'

      response '200', 'Organization list generated' do
        run_test!
      end
    end

    post 'Create Organization' do
      tags 'Organizations'
      consumes 'application/json'

      response '200', 'Organization created' do
        run_test!
      end
      response '401', 'Not logged in as a SuperAdmin' do
        run_test!
      end
      response '422', 'Name or slug already taken' do
        run_test!
      end
    end
  end
end
