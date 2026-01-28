# frozen_string_literal: true

class Appointment < ApplicationRecord
  validates :full_name, :email, :phone, :service_type, :preferred_date, :preferred_time, presence: true
end
