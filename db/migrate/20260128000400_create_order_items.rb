# frozen_string_literal: true

class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, null: false, precision: 12, scale: 2, default: 0

      t.timestamps
    end
  end
end
