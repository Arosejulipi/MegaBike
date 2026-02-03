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
      expose: ENV['EXPOSE_ERRORS_PUBLIC']
    }

    render json: results
  end
end
