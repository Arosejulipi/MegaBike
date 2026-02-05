# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  enum role: { customer: 0, admin: 1 }

  has_many :orders, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
