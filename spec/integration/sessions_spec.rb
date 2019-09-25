require 'swagger_helper'

describe 'Session Management API' do
  path '/login' do
    post 'Login' do
      tags 'Sessions'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
          type: :object,
          properties: {
              email: {type: :string},
              password: {type: :string},
          }
      }

      response '200', 'Login successful' do
        run_test!
      end
    end
  end
end


