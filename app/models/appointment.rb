# frozen_string_literal: true

class Appointment < ApplicationRecord
  validates :full_name, :email, :service_type, :preferred_date, :preferred_time, presence: true

  validate :preferred_time_is_allowed

  def self.allowed_time_options
    morning = build_slots("08:30", "13:30", step_minutes: 30)
    afternoon = build_slots("16:00", "19:00", step_minutes: 30)
    morning + afternoon
  end

  # Used by the form to make it obvious that there are two ranges.
  def self.allowed_time_groups
    {
      "Manana" => build_slots("08:30", "13:30", step_minutes: 30),
      "Tarde" => build_slots("16:00", "19:00", step_minutes: 30)
    }
  end

  def self.build_slots(start_hhmm, end_hhmm, step_minutes:)
    start_minutes = to_minutes(start_hhmm)
    end_minutes = to_minutes(end_hhmm)
    return [] if start_minutes.nil? || end_minutes.nil? || step_minutes.to_i <= 0

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

  def self.to_minutes(hhmm)
    parts = hhmm.to_s.split(":")
    return nil unless parts.length == 2
    hh = Integer(parts[0], exception: false)
    mm = Integer(parts[1], exception: false)
    return nil if hh.nil? || mm.nil?
    (hh * 60) + mm
  end

  private

  def preferred_time_is_allowed
    return if preferred_time.blank?

    normalized = preferred_time.to_s.strip
    return if self.class.allowed_time_options.include?(normalized)

    errors.add(:preferred_time, "debe estar entre 08:30-13:30 o 16:00-19:00")
  end
end
