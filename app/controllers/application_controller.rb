class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def append_info_to_payload(payload)
    super
    payload[:cookie] = request.headers['Cookie']
  end

  before_action :set_locale
  
  def set_locale
    if defined?(params) && params[:locale]
      I18n.locale = params[:locale]
    elsif defined?(request)
      I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE']
    else
      I18n.locale = I18n.default_locale
    end

    I18n.locale ||= I18n.default_locale
  end
end
