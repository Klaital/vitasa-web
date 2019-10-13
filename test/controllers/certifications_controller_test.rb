require 'test_helper'

class CertificationsControllerTest < ActionDispatch::IntegrationTest
  test "anyone can list certifications" do
    get certifications_path, headers: {
        'Accept' => 'application/json'
    }
    assert_response :success
  end
  test "admins can create certifications" do
    admin_cookie = login_user('user-one', ['Admin'])
    assert_not_nil(admin_cookie)
    assert(admin_cookie.length > 0)

    assert_difference('Certification.count', 1) do
      post certifications_path, headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => admin_cookie,
      }, params: {
          'name' => 'Test Certification',
      }.to_json
      assert_response :success
    end
    assert_not_nil(Certification.last.organization_id)
    assert_equal(users(:one).organization_id, Certification.last.organization_id, 'Cert was not created in the user\'s org')
  end

  test "admins can grant certifications" do
    admin_cookie = login_user('user-one', ['Admin'])
    assert_not_nil(admin_cookie)
    assert(admin_cookie.length > 0)

    assert_difference('CertificationGrant.count', 1) do
      put "/users/#{users(:two).id}/certifications/#{certifications(:sa_cert_one).id}", headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => admin_cookie,
      }
      assert_response :success
    end
  end
  test "admins can revoke certifications" do
    admin_cookie = login_user('user-one', ['Admin'])
    assert_not_nil(admin_cookie)
    assert(admin_cookie.length > 0)

    # First validate 404 response when trying to revoke a cert that has not been granted
    assert_no_difference('CertificationGrant.count') do
      delete "/users/#{users(:two).id}/certifications/#{certifications(:sa_cert_one).id}", headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => admin_cookie,
      }
      assert_response :not_found
    end

    # Grant a cert
    put "/users/#{users(:two).id}/certifications/#{certifications(:sa_cert_one).id}", headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => admin_cookie,
    }
    assert_response :success

    # Validate revoking it
    assert_difference('CertificationGrant.count', -1) do
      delete "/users/#{users(:two).id}/certifications/#{certifications(:sa_cert_one).id}", headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => admin_cookie,
      }
      assert_response :success
    end
  end


  test "users cannot grant own certifications" do
    cookie = login_user('user-one', ['Volunteer'])

    assert_no_difference('CertificationGrant.count') do
      put "/users/#{users(:one).id}/certifications/#{certifications(:sa_cert_one).id}", headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
      }
      assert_response :unauthorized
    end
  end

  test "users cannot remove certifications" do
    cookie = login_user('user-one', ['Volunteer'])

    assert_no_difference('CertificationGrant.count') do
      delete "/users/#{users(:one).id}/certifications/#{certifications(:sa_cert_one).id}", headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
      }
      assert_response :unauthorized
    end
  end

  test "user certs are included in their details" do
    cookie = login_user('user-one', ['Admin'])
    uut = users(:two)
    uut.certifications = [ certifications(:sa_cert_one) ]

    get "/users/#{uut.id}", headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }
    assert_response :success
    userJson = JSON.parse(response.body)
    assert_equal(1, userJson['certifications'].length)
    assert_equal('Paperwork Signed', userJson['certifications'][0]['name'])
  end
end
