class ApplicationJob < ActiveJob::Base
  queue_as Conf.tenant
  include Rails.application.routes.url_helpers

  protected
  def default_url_options
    Rails.application.routes.default_url_options
  end
end
