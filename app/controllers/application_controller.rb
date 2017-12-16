class ApplicationController < ActionController::Base
  require 'csv'
  protect_from_forgery with: :exception
  include SessionsHelper
  include CachingHelper

  def append_info_to_payload(payload)
    super
    payload[:cookie] = request.headers['Cookie']
  end

  before_action :set_locale
  
  def set_locale
    if defined?(params) && params[:locale]
      I18n.locale = params[:locale]
    elsif defined?(request) && !request.env['HTTP_ACCEPT_LANGUAGE'].nil?
      I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE'][0..1]
    else
      I18n.locale = I18n.default_locale
    end

    I18n.locale ||= I18n.default_locale
  end
end
