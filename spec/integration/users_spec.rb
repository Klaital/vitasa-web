require 'swagger_helper'

describe 'Users API' do
  path '/users' do

    post 'Registers a new user' do
      tags 'Users'
      consumes 'application/json'

      parameter name: :user, in: :body, schema: {
          type: :object,
          properties: {
              name: { type: :string },
              email: { type: :string },
              password: { type: :string },
              phone: {type: :string},
          }
      }

      response '200', 'User registered' do
        let(:user) { {name: 'John Smith', email: 'johnsmith@example.org', password: 'password123', phone: '555-111-2222'}}
        run_test!
      end

    end

    get 'Fetches a list of all users' do
      tags 'Users'
      produces 'application/json'
      response '200', 'User list generated' do
        run_test!
      end
    end

  end

  path '/users/{id}' do
    get 'Describe User' do
      tags 'Users'
      produces 'application/json'

      response '200', 'User list generated' do
        run_test!
      end
    end
  end
end