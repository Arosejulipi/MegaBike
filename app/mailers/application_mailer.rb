# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: (ENV["DEFAULT_FROM_EMAIL"] || "no-reply@megabike.local")
  layout "mailer"
end
