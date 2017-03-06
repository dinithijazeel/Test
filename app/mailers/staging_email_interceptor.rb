class StagingEmailInterceptor
  def self.delivering_email(message)
    if Conf.staging.engaged
      original_to = message.to
      original_to = message.to[0] if message.to.is_a?(Array)
      message.subject = "TEST [#{original_to}] - " + message.subject
      message.to = Conf.staging.email
      message.cc = nil
    else
      message.bcc = Conf.staging.email
    end
  end
end
