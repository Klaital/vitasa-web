require 'swagger_helper'

describe 'Sites API' do
  path '/sites' do
    get 'Fetch all sites' do
      tags 'Sites'
      produces 'application/json'

      response '200', 'Sites listed' do
        run_test!
      end
    end

    post 'Create new site' do
      tags 'Sites'
      consumes 'application/json'
      produces 'application/json'

      response '200', 'Site created' do
        run_test!
      end

      response '401', 'Not logged in to an admin account' do
        run_test!
      end
    end
  end

  path '/sites/{slug}' do
    get 'Describe site' do
      tags 'Sites'
      produces 'application/json'

      response '200', 'Site details returned' do
        run_test!
      end
    end

    put 'Update site data' do
      tags 'Sites'
      produces 'application/json'
      consumes 'application/json'

      response '200', 'Site updated' do
        run_test!
      end
      response '401', 'Not logged in as an admin or a coordinator assigned to this site' do
        run_test!
      end

      response '400', 'Bad or incomplete data' do
        run_test!
      end
      response '422', 'Invalid data submitted' do
        run_test!
      end
    end

    delete 'Destroy site' do
      tags 'Sites'

      response '200', 'Site deleted' do
        run_test!
      end
      response '401', 'Not logged in as an admin' do
        run_test!
      end
    end
  end
end
