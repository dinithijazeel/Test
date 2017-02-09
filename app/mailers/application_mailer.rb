class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.x.company.email
end
