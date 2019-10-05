require 'test_helper'

class WorkLogsControllerTest < ActionDispatch::IntegrationTest
  test "users should be able to log work" do
    user = users(:one)
    cookie = login_user("user-one")
    work_log = {
        site: sites(:the_cathedral).slug,
        hours: 4.0,
        date: (Date.today-1).strftime('%Y-%m-%d'),
    }
    assert_difference('WorkLog.count', 1) do
      post user_work_logs_path(user),
         :params => work_log.to_json,
         :headers => {
             'Accept' => 'application/json',
             'Content-Type' => 'application/json',
             'Cookie' => cookie,
         }
      assert_response :success
    end

    # Parse the response, and ensure that the newly-created Log is actually present
    user_data = JSON.parse(response.body)
    user_log_ids = user_data['work_history'].collect {|x| x['id']}
    wlog = WorkLog.last
    assert_not_nil(wlog.site)
    assert(user_log_ids.include?(wlog.id), 'New Work Log not found in response')
  end

  test "site coordinators should be able to approve work" do
    volunteer = users(:one)
    sc = users(:two)
    volunteer_cookie = login_user('user-one', ['Volunteer'])
    sc_cookie = login_user('user-two', ['SiteCoordinator'])

    work_log = {
        site: sites(:the_cathedral).slug,
        hours: 4,
        date: (Date.today-1).strftime('%Y-%m-%d'),
    }
    post user_work_logs_path(volunteer),
         :params => work_log.to_json,
         :headers => {
             'Accept' => 'application/json',
             'Content-Type' => 'application/json',
             'Cookie' => volunteer_cookie,
         }
    assert_response :success
    assert(1, volunteer.work_logs.length)
    assert_equal(false, WorkLog.last.approved?)
    puts "Generated worklog #{WorkLog.last.id}"

    # TODO: The volunteer should not be able to approve the hours himself
    # put user_work_log_path(volunteer, WorkLog.last),
    #     :params => {
    #         :approved => true
    #     }.to_json,
    #     :headers => {
    #         'Accept' => 'application/json',
    #         'Content-Type' => 'application/json',
    #         'Cookie' => volunteer_cookie,
    #     }
    # assert_response :unathorized
    # assert_equal(false, WorkLog.last.approved?)

    # The SC should be able to approve the time
    put user_work_log_path(volunteer, WorkLog.last),
        :params => {
            :approved => true
        }.to_json,
        :headers => {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'Cookie' => sc_cookie,
        }
    assert_response :success
    assert_equal(true, WorkLog.last.approved?)
  end

  test 'should be able to delete a log' do
    user = users(:one)
    cookie = login_user("user-one")
    work_log = {
        site: sites(:the_cathedral).slug,
        hours: 4.0,
        date: (Date.today-1).strftime('%Y-%m-%d'),
    }
    assert_difference('WorkLog.count', 1) do
      post user_work_logs_path(user),
           :params => work_log.to_json,
           :headers => {
               'Accept' => 'application/json',
               'Content-Type' => 'application/json',
               'Cookie' => cookie,
           }
      assert_response :success
    end

    wlog = WorkLog.last
    assert_difference('WorkLog.count', -1) do
      delete user_work_log_path(user, wlog),
           :headers => {
               'Accept' => 'application/json',
               'Content-Type' => 'application/json',
               'Cookie' => cookie,
           }
      assert_response :success
    end
  end
end
