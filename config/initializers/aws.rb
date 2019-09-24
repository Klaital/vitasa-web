Rails.application.configure do 
    config.sns_gcm_application_arn = ENV['SNS_GCM_ARN']
    config.sns_apn_application_arn = ENV['SNS_APN_ARN']
end
