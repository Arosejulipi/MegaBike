# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.text    :description
      t.decimal :price, null: false, precision: 12, scale: 2, default: 0
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.string  :image_url

      t.timestamps
    end
  end
end
