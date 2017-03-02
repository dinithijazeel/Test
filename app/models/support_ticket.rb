class SupportTicket < ActiveRecord::Base
  #
  ## Associations
  #
  belongs_to :supportable, polymorphic: true
  #
  ## Enumerations
  #
  enum :system => [:internal, :freshdesk]
  #
  # Callbacks
  #
  before_create do
    unless internal?
      self.foreign_id = create_remote
    end
  end

  def create_remote
    url  = "#{Rails.application.config.x.freshdesk.url}api/v2/tickets"
    api_key = Rails.application.config.x.freshdesk.api_key
    payload = supportable.external_ticket_params
    site = RestClient::Resource.new(url, api_key, 'X')
    begin
      if payload[:attachments]
        payload[:attachments] = payload[:attachments].collect { |path| File.new(path,'rb') }
        response = site.post(payload)
      else
        response = site.post(payload.to_json, :content_type=>'application/json')
      end
      # Return created ID
      JSON.parse(response.body)['id']
    rescue RestClient::Exception => exception
      puts 'API Error: Your request is not successful. If you are not able to debug this error properly, mail us at support@freshdesk.com with the follwing X-Request-Id'
      puts "X-Request-Id : #{exception.response.headers[:x_request_id]}"
      puts "Response Code: #{exception.response.code} \nResponse Body: #{exception.response.body} \n"
    end
  end

  def read_remote
    url  = "#{Rails.application.config.x.freshdesk.url}api/v2/tickets/#{foreign_id}"
    api_key = Rails.application.config.x.freshdesk.api_key
    site = RestClient::Resource.new(url, api_key, 'X')
    begin
      response = site.get
      JSON.parse(response.body)
    rescue RestClient::Exception => exception
      puts 'API Error: Your request is not successful. If you are not able to debug this error properly, mail us at support@freshdesk.com with the follwing X-Request-Id'
      puts "X-Request-Id : #{exception.response.headers[:x_request_id]}"
      puts "Response Code: #{exception.response.code} \nResponse Body: #{exception.response.body} \n"
    end
  end
end
