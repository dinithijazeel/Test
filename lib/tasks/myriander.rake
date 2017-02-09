namespace :myriander do

  # Remove service invoices
  #
  # DELETE FROM `line_items` WHERE `bom_id` IN (SELECT `id` FROM `boms` WHERE `type`='ServiceInvoice');
  # DELETE FROM `boms` WHERE `type`='ServiceInvoice';
  # DELETE FROM `comments` WHERE `user_id` = 182;

  desc "Post service invoice files"
  task post_si: :environment do
    Dir.foreach("#{Rails.application.root}/service_invoices") do |item|
      next unless item =~ /json$/
      # url  = 'https://dev-my.fractel.com'
      url  = 'http://localhost:3000'
      username = ENV['PORTAL_USERNAME']
      password = ENV['PORTAL_PASSWORD']
      site = RestClient::Resource.new(url, username, password)
      json = File.read("#{Rails.application.root}/service_invoices/#{item}")
      json = "{\"Invoice\":#{json}}"
      # print "@@@\n#{json}\n@@@\n"
      begin
        response = site['admin/service_invoices'].post(json, {content_type: :json, accept: :json})
        response = JSON.parse(response.body)
      rescue RestClient::Exception => exception
        puts 'API Error: Your request is not successful. If you are not able to debug this error properly, mail us at support@freshdesk.com with the follwing X-Request-Id'
        puts "X-Request-Id : #{exception.response.headers[:x_request_id]}"
        puts "Response Code: #{exception.response.code} \nResponse Body: #{exception.response.body} \n"
      end
      print "#{item} : #{response}\n"
      # break
    end
  end

  desc "Test some stuff"
  task test: :environment do
    invoice = JSON.parse(File.read("#{Rails.application.root}/fractelinvoice3.json"))
    api_invoice = Invoice.parse_portal(invoice["Invoice"])
    # print "#{api_invoice.to_yaml}\n"
    print "Received #{api_invoice[:number]}\n"
    invoice = Invoice.new(api_invoice)
    if invoice.save
      # Obsolete existing invoice if it's a duplicate number
      if existing_invoice = Invoice
          .where(:number => api_invoice[:number])
          .where.not(:invoice_status => Invoice.invoice_statuses[:obsolete])
          .where.not(:id => invoice.id)
          .first
        existing_invoice.update_attribute(:invoice_status, Invoice.invoice_statuses[:obsolete])
        message = "Replaced invoice #{existing_invoice.number} (#{existing_invoice.id} with #{invoice.id})\n"
        Comment.build_from(invoice.contact, 1, message).save
        print "#{message}\n"
        # Comment.build_from(@invoice.contact, current_user.id, message).save
        # logger.debug "#{existing_invoice.to_yaml}\n"
      end
      print "Saved invoice #{invoice.id}\n"
    else
      print "#{invoice.errors.as_json}\n"
    end
  end

end
