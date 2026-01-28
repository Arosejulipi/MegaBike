# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@megabike.local"
  layout "mailer"
end
