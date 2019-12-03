require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = sites(:the_alamo)
    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    user_role = Role.find_by(name: 'None')
    @new_user.roles = [ user_role ]

    @admin = users(:two)
    user_role = Role.find_by(name: 'Admin')
    @admin.roles = [ user_role ]

    @volunteer = users(:volunteer_one)
    user_role = Role.find_by(name: 'Volunteer')
    @volunteer.roles = [ user_role ]

    user_role = Role.find_by(name: 'SiteCoordinator')
    @sc1 = users(:three)
    @sc1.roles = [ user_role ]
    @site.sitecoordinator = @sc1.id
    @site.save
    
    @sc2 = users(:four)
    @sc2.roles = [ user_role ]
    @cathedral.sitecoordinator = @sc2.id
    @cathedral.save

    @reviewer = users(:reviewer_one)
    @reviewer.roles = [ Role.find_by(name: 'Reviewer')]

    @suggestion = suggestions(:one)
  end

  test "should get index" do
    get suggestions_url
    assert_response :success
  end

  test "should get new" do
    get new_suggestion_url
    assert_response :success
  end

  test "should create suggestion when not logged in" do
    assert_difference('Suggestion.count', 1) do
      post suggestions_url, params: { suggestion: { 
        details: @suggestion.details, 
        subject: @suggestion.subject, 
        from_public: false
      }}
    end
    assert_redirected_to Suggestion.last

    # Validate that the from_public field was forced to true
    suggestion = Suggestion.last
    assert_equal(true, suggestion.from_public)
  end

  test "should create suggestion when logged in as any user" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    assert_response 302

    assert_difference('Suggestion.count') do
      post suggestions_url, params: { suggestion: { 
        details: @suggestion.details, 
        subject: @suggestion.subject, 
      }}
    end

    assert_redirected_to suggestion_url(Suggestion.last)
  end

  test "should create suggestion via JSON when logged in as any user" do
    post login_url, 
    params: {
      email: @admin.email,
      password: 'user-two-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
  
    assert_difference('Suggestion.count') do
      post suggestions_url, params: {  
        details: "should create suggestion via JSON when logged in as any user: details", 
        subject: "should create suggestion via JSON when logged in as any user: subject", 
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
    end
    assert_response(201)

    # Validate that all records were saved
    suggestion = Suggestion.last
    assert_equal("should create suggestion via JSON when logged in as any user: details", suggestion.details)
    assert_equal("should create suggestion via JSON when logged in as any user: subject", suggestion.subject)
    assert_equal(false, suggestion.from_public)
    assert_equal('Open', suggestion.status)
  end

  test "should create suggestion via JSON when logged in as volunteer" do
    post login_url, 
    params: {
      email: @volunteer.email,
      password: 'volunteer-one-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
  
    assert_difference('Suggestion.count') do
      post suggestions_url, params: {  
        details: "should create suggestion via JSON when logged in as volunteer: details", 
        subject: "should create suggestion via JSON when logged in as volunteer: subject", 
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
    end
    assert_response(201)

    # Validate that all records were saved
    suggestion = Suggestion.last
    assert_equal("should create suggestion via JSON when logged in as volunteer: details", suggestion.details, 'Failed to set details with new suggestion creation')
    assert_equal("should create suggestion via JSON when logged in as volunteer: subject", suggestion.subject, 'Failed to set subject with new suggestion creation')
    assert_equal(false, suggestion.from_public)
    assert_equal('Open', suggestion.status)
  end

  test "should only be able to update the status field when logged in as a reviewer" do
    post login_url, 
    params: {
      email: @reviewer.email,
      password: 'reviewer-one-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
  
    patch suggestion_url(@suggestion), params: {  
        details: "new details", 
        subject: "new subject", 
        status: 'Closed'
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response(:success)

    # Validate that all records were saved
    suggestion = Suggestion.find(@suggestion.id)
    assert_equal("Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.", suggestion.details, 'Should have failed to set details with reviewer update')
    assert_equal("A suggestion", suggestion.subject, 'Should have failed to set subject with reviewer update')
    assert_equal('Closed', suggestion.status, 'Failed to update status as a reviewer.')
  end


  test "should show suggestion" do
    get suggestion_url(@suggestion)
    assert_response :success
  end

  test "should get edit" do
    get edit_suggestion_url(@suggestion)
    assert_response :success
  end

  test "should update suggestion when logged in as the owning user" do
    post login_path, params: {session: {email: @volunteer.email, password: 'volunteer-one-password'}}
    patch suggestion_url(@suggestion), params: { suggestion: { 
      details: @suggestion.details + 'a', 
      subject: @suggestion.subject
    }}
    
    assert_redirected_to suggestion_url(@suggestion)
    
    # Load the updated suggestion, and check that it's been altered
    assert_equal(@suggestion.details + 'a', Suggestion.find(@suggestion.id).details)
  end
  test "should fail to update suggestion when logged in as any other user" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    patch suggestion_url(@suggestion), params: { suggestion: { 
      details: @suggestion.details, 
      subject: @suggestion.subject
    }}
    assert_response :unauthorized
  end

  test "should delete suggestion when logged in as the owning user" do
    post login_path, params: {session: {email: @volunteer.email, password: 'volunteer-one-password'}}
    assert_difference('Suggestion.count', -1) do
      delete suggestion_url(@suggestion)
    end
    assert_redirected_to new_suggestion_url
  end
  test "should delete suggestion when logged in as an admin" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    assert_difference('Suggestion.count', -1) do
      delete suggestion_url(@suggestion)
    end
    assert_redirected_to new_suggestion_url
  end
  
  test "should fail to delete suggestion when logged in as any other user" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    assert_no_difference('Suggestion.count') do
      delete suggestion_url(@suggestion)
    end
    assert_response :unauthorized
  end
end
