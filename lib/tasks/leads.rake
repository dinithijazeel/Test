namespace :leads do

  def parse_lead(html, source = :connect_360)
    # Parse lead
    lead = {
      customer_status: Contact.customer_statuses[:opportunity],
    }
    page = Nokogiri::HTML(html)
    case source
    when :connect_360
      lead[:affiliate_code] = '360connect'
      # Get contact block and split into pieces
      parts = page.css('td.buffered p')
      main_contact = parts[0].inner_html
      location = parts[1].inner_html
      comments = parts[2].inner_html
      main_contact_parts = main_contact.split("<br>")
      # First name, last name
      /^(.*) ([^ ]*)$/.match(main_contact_parts[0]) do |name|
        lead[:contact_first] = name[1]
        lead[:contact_last] = name[2]
      end
      # Company name
      lead[:company_name] = main_contact_parts[1]
      # Phone
      lead[:phone] = Nokogiri::HTML(main_contact_parts[2]).text
      # Emails
      lead[:admin_email] = Nokogiri::HTML(main_contact_parts[3]).text
      # City, State, Zip
      location_parts = location.split("<br>")
      lead[:billing_zip] = location_parts[0].squish.match(/\d+$/).to_s if location_parts[0]
      /^(.*), ([^,]*)$/.match(location_parts[1]) do |city_state|
        lead[:billing_city] = city_state[1]
        lead[:billing_state] = city_state[2]
      end
      # Comments
      comment_parts = comments.split("<br>")
      lead[:comment] = comment_parts[1].squish
      # Additional information
      lead[:comment] += "\n\n" + parts[3..5].collect { |comment| comment.inner_html }.join("\n\n")
    end
    lead.transform_values { |v| v.strip if v.is_a?(String) }
  end

  task fetch: :environment do
    print "leads:fetch - Run #{Time.now}\n"
    Gmail.connect!(Rails.application.secrets.leads_username, Rails.application.secrets.leads_password) do |gmail|
      lead_sources = {
        connect_360: 'telecommunications@360connect.com',
      }
      html = ""
      gmail.mailbox('[Gmail]/All Mail').emails(gm: 'in:inbox').each do |m|
        from = "#{m.from[0].mailbox}@#{m.from[0].host}"
        if source = lead_sources.key(from)
          if m.multipart?
            # TODO: This could be better, but no multipart samples to work with
            m.parts.each { |p|
              if p.content_type.starts_with?('text/html')
                html = p.body.decoded
                break
              end
            }
          else
            html = m.body.decoded
          end
          record = parse_lead(html, source)
          comment = record.delete(:comment)
          contact = Contact.find_by_admin_email(record[:admin_email])
          if contact
            # Do not update customers with a portal account
            contact.update(record) unless contact.has_portal_account?
            # Touch contact so it comes to the top
            contact.touch
          else
            contact = Contact.new(record)
            contact.save
          end
          Comment.build_from(contact, Conf.id.default_user_id, comment).save
          m.move_to('Processed')
          print "Process - "
        else
          m.move_to('Ignored')
          print "Ignore - "
        end
        # m.remove_label('\\Inbox')
        m.archive!
        print "#{from} -- #{m.subject}\n"
      end
    end
  end
end
