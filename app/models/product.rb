# frozen_string_literal: true

class Product < ApplicationRecord
  scope :available, -> { where(active: true).where("stock > 0") }

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
