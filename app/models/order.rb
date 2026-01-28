# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  def total
    order_items.sum { |i| i.quantity * i.unit_price }
  end
end
