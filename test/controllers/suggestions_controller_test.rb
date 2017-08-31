require 'test_helper'

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = sites(:the_alamo)
    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    user_role = Role.find_by(name: 'NewUser')
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

  test "should not create suggestion when not logged in" do
    assert_no_difference('Suggestion.count') do
      post suggestions_url, params: { suggestion: { 
        details: @suggestion.details, 
        subject: @suggestion.subject, 
      }}
    end
    assert_response :unauthorized
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
