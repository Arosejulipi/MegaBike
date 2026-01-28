# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  enum role: { customer: 0, admin: 1 }

  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
