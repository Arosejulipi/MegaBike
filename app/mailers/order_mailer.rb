# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  ADMIN_EMAILS = (ENV["ADMIN_EMAILS"] || ENV["MEGABIKE_OWNER_EMAIL"] || "duenios@megabike.com")

  def order_request(order)
    @order = order
    recipients = ADMIN_EMAILS.split(/,\s*/).reject(&:blank?)
    mail(to: recipients, subject: "Nueva compra - Mega Bike")
  end

  def order_confirmation(order)
    @order = order
    mail(to: @order.user.email, subject: "Confirmación de compra - Mega Bike")
  end
end
