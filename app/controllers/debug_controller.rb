# frozen_string_literal: true

class DebugController < ApplicationController
  # Only used when EXPOSE_ERRORS_PUBLIC=1
  def trigger
    raise "Intentional debug exception (triggered by /__trigger_error)"
  end

  def status
    render json: {
      expose: ENV['EXPOSE_ERRORS_PUBLIC'] == '1',
      last_error_exists: File.exist?(Rails.root.join('public', 'last_error.log'))
    }
  end
end
