# frozen_string_literal: true

class DebugController < ApplicationController
  # Only used when EXPOSE_ERRORS_PUBLIC=1
  def trigger
    # write a marker to verify the process can create the public file
    begin
      log_path = Rails.root.join('public', 'last_error.log')
      File.write(log_path, "Triggered at #{Time.current}\n")
    rescue => e
      Rails.logger.error "Failed writing trigger marker: #{e.class}: #{e.message}"
    end
    raise "Intentional debug exception (triggered by /__trigger_error)"
  end

  def status
    render json: {
      expose: ENV['EXPOSE_ERRORS_PUBLIC'] == '1',
      last_error_exists: File.exist?(Rails.root.join('public', 'last_error.log'))
    }
  end

  def diagnose
    return head :forbidden unless ENV['EXPOSE_ERRORS_PUBLIC'] == '1'

    results = {}
    public_dir = Rails.root.join('public')
    results[:public_dir_exists] = Dir.exist?(public_dir)
    results[:public_dir_mode] = File.stat(public_dir).mode.to_s(8) rescue nil

    # try write a temp file in tmp
    begin
      tmp_path = Rails.root.join('tmp', "diag_#{Time.now.to_i}.txt")
      File.write(tmp_path, "diag #{Time.now}\n")
      results[:tmp_write_ok] = File.exist?(tmp_path)
      results[:tmp_contents] = File.read(tmp_path)
      File.delete(tmp_path) if File.exist?(tmp_path)
    rescue => e
      results[:tmp_write_error] = "#{e.class}: #{e.message}"
    end

    # try write to public
    begin
      pub_test = public_dir.join('diag_public_test.txt')
      File.write(pub_test, "pub diag #{Time.now}\n")
      results[:public_write_ok] = File.exist?(pub_test)
      results[:public_contents] = File.read(pub_test) if File.exist?(pub_test)
      File.delete(pub_test) if File.exist?(pub_test)
    rescue => e
      results[:public_write_error] = "#{e.class}: #{e.message}"
    end

    # List a few env vars that matter (mask sensitive)
    results[:env] = {
      rails_env: ENV['RAILS_ENV'],
      app_host: ENV['APP_HOST'],
      expose: ENV['EXPOSE_ERRORS_PUBLIC'],
      smtp_address_set: ENV["SMTP_ADDRESS"].present?,
      smtp_username_set: ENV["SMTP_USERNAME"].present?,
      smtp_password_set: ENV["SMTP_PASSWORD"].present?,
      admin_emails_set: ENV["ADMIN_EMAILS"].present?,
      admin_emails: ENV["ADMIN_EMAILS"],
      default_from_email_set: ENV["DEFAULT_FROM_EMAIL"].present?,
      default_from_email: ENV["DEFAULT_FROM_EMAIL"],
      email_webhook_set: ENV["EMAIL_WEBHOOK_URL"].present?,
      email_webhook_url: ENV["EMAIL_WEBHOOK_URL"]
    }

    # Show mailer config summary (no secrets)
    results[:mailer] = {
      perform_deliveries: Rails.application.config.action_mailer.perform_deliveries,
      raise_delivery_errors: Rails.application.config.action_mailer.raise_delivery_errors,
      delivery_method: Rails.application.config.action_mailer.delivery_method.to_s
    }

    render json: results
  end

  # Send test emails immediately (deliver_now). Only when EXPOSE_ERRORS_PUBLIC=1
  def send_test_email
    return head :forbidden unless ENV['EXPOSE_ERRORS_PUBLIC'] == '1'

    recipient = params[:email].presence || ENV['SMTP_TEST_RECIPIENT'] || 'admin@megabike.com'
    appt = Appointment.new(
      full_name: "Debug Tester",
      email: recipient,
      service_type: 'Debug',
      preferred_date: Date.today,
      preferred_time: '10:00'
    )

    owner_ok = MailerDeliveryService.deliver(OwnerMailer.appointment_request(appt))
    client_ok = MailerDeliveryService.deliver(OwnerMailer.appointment_confirmation(appt))

    status = (owner_ok && client_ok) ? :ok : :bad_gateway
    render plain: "Test email results => owner_ok=#{owner_ok} client_ok=#{client_ok} recipient=#{recipient}", status: status
  rescue => e
    if ENV['EXPOSE_ERRORS_PUBLIC'] == '1'
      begin
        log_path = Rails.root.join('public', 'last_error.log')
        File.write(log_path, "Exception: #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}\n")
      rescue => fw
        Rails.logger.error "Failed writing last_error.log: #{fw.class}: #{fw.message}"
      end
    end

    render plain: "Error sending test emails: #{e.class}: #{e.message}", status: :internal_server_error
  end

  # Debug helper to see webhook HTTP response. Only when EXPOSE_ERRORS_PUBLIC=1
  def test_email_webhook
    return head :forbidden unless ENV['EXPOSE_ERRORS_PUBLIC'] == '1'
    return render json: { configured: false }, status: :unprocessable_entity unless EmailWebhookService.configured?

    recipient = params[:email].presence || ENV['SMTP_TEST_RECIPIENT'] || 'admin@megabike.com'
    result = EmailWebhookService.request_email(
      to: recipient,
      subject: "MegaBike webhook test",
      html_body: "<p>Webhook OK</p>",
      text_body: "Webhook OK"
    )

    render json: result.merge(to: recipient), status: (result[:success] ? :ok : :bad_gateway)
  end
end
