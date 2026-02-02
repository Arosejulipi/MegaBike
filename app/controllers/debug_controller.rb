# frozen_string_literal: true

class DebugController < ApplicationController
  # Only used when EXPOSE_ERRORS_PUBLIC=1
  def trigger
    raise "Intentional debug exception (triggered by /__trigger_error)"
  end
end
