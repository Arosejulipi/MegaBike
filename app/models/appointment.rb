# frozen_string_literal: true

class Appointment < ApplicationRecord
  validates :full_name, :email, :service_type, :preferred_date, :preferred_time, presence: true

  validate :preferred_time_is_allowed

  def self.allowed_time_options
    morning_slots + afternoon_slots
  end

  def self.morning_slots
    build_slots_minutes((8 * 60) + 30, (13 * 60) + 30, step_minutes: 30)
  end

  def self.afternoon_slots
    build_slots_minutes(16 * 60, 19 * 60, step_minutes: 30)
  end

  def self.build_slots_minutes(start_minutes, end_minutes, step_minutes:)
    start_minutes = start_minutes.to_i
    end_minutes = end_minutes.to_i
    step_minutes = step_minutes.to_i
    return [] if step_minutes <= 0
    return [] if start_minutes <= 0 || end_minutes <= 0
    return [] if start_minutes > end_minutes

    slots = []
    m = start_minutes
    while m <= end_minutes
      hh = (m / 60).to_s.rjust(2, "0")
      mm = (m % 60).to_s.rjust(2, "0")
      slots << "#{hh}:#{mm}"
      m += step_minutes
    end
    slots
  end

  private

  def preferred_time_is_allowed
    return if preferred_time.blank?

    normalized = preferred_time.to_s.strip
    return if self.class.allowed_time_options.include?(normalized)

    errors.add(:preferred_time, "debe estar entre 08:30-13:30 o 16:00-19:00")
  end
end
