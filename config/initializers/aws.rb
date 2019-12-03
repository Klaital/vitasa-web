Rails.application.configure do 
  config.sns_gcm_application_arn = ENV['SNS_GCM_ARN'] | 'arn:aws:sns:us-west-2:813809418199:app/GCM/VITA-GCM'
  config.sns_apn_application_arn = ENV['SNS_APN_ARN'] | 'arn:aws:sns:us-west-2:813809418199:app/APNS/VITA-APNS'
  config.sns = Aws::SNS::Client.new(region: 'us-west-2')

  if Rails.env.test?
    config.sns = Aws::SNS::Client.new(region: 'us-west-2', stub_responses: true)
    config.sns.stub_responses(:subscribe, -> (context) {{subscription_arn: SecureRandom.uuid}})
    config.sns.stub_responses(:unsubscribe, -> (context) {{}})
    config.sns.stub_responses(:publish, -> (context) {
      {message_id: SecureRandom.uuid}
    })
    config.sns.stub_responses(:create_topic, -> (context) {{topic_arn: SecureRandom.uuid}})
    config.sns.stub_responses(:delete_topic, -> (context) {{}})
  end
end
