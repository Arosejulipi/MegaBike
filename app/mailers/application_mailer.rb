# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", ENV.fetch("SMTP_USERNAME", "no-reply@megabike.local"))
  layout "mailer"
end
