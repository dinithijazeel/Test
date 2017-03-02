class StagingEmailInterceptor
  def self.delivering_email(message)
    if Rails.application.config.x.staging
      message.subject = 'TEST - ' + message.subject
      message.to = Rails.application.config.x.email.staging_email
      message.cc = nil
    else
      message.bcc = Rails.application.config.x.email.staging_email
    end
  end
end
