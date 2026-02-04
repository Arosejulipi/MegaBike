if Rails.env.production?
  if ENV['POSTMARK_API_TOKEN'].present?
    Rails.application.config.action_mailer.delivery_method = :postmark
    Rails.application.config.action_mailer.postmark_settings = {
      api_token: ENV['POSTMARK_API_TOKEN']
    }
  end
end

# In non-production you can keep :smtp or :letter_opener_web (dev)