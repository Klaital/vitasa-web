class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def append_info_to_payload(payload)
    super
    payload[:cookie] = request.headers['Cookie']
  end
end
