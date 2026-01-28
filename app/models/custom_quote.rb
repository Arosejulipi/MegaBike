# frozen_string_literal: true

class CustomQuote < ApplicationRecord
  validates :full_name, :email, :phone, :bike_type, :budget_range, presence: true
end
