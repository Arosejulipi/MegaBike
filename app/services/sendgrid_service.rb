# frozen_string_literal: true

require "sendgrid-ruby"

class SendgridService
  include SendGrid

  def self.send_email(to:, subject:, html_body:, text_body:, from:)
    api_key = ENV['SENDGRID_API_KEY']
    return false unless api_key.present?

    sg = SendGrid::API.new(api_key: api_key)

    to_list = Array(to).map { |addr| { email: addr } }

    data = {
      personalizations: [
        {
          to: to_list
        }
      ],
      from: { email: from },
      subject: subject,
      content: []
    }

    data[:content] << { type: 'text/plain', value: text_body } if text_body.present?
    data[:content] << { type: 'text/html', value: html_body } if html_body.present?

    begin
      sg.client.mail._('send').post(request_body: data)
      true
    rescue => e
      Rails.logger.error "SendgridService error: #{e.class}: #{e.message}"
      false
    end
  end
end
