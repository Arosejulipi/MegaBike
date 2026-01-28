# frozen_string_literal: true

class CreateCustomQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :custom_quotes do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone, null: false

      t.string :bike_type, null: false
      t.string :frame_size
      t.string :color
      t.string :brakes
      t.string :gears
      t.string :budget_range, null: false
      t.text :extra_notes

      t.timestamps
    end
  end
end
