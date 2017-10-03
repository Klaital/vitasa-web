Rails.application.configure do 
    config.sns_gcm_application_arn = 'arn:aws:sns:us-west-2:813809418199:app/GCM/VITA-GCM'
    config.sns_apn_application_arn = ''
    config.sns_topic_volunteers_arn = 'arn:aws:sns:us-west-2:813809418199:vita-notification-volunteers'
    config.sns_topic_sc_arn = 'arn:aws:sns:us-west-2:813809418199:vita-notification-sc'
end
