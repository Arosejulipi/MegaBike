# frozen_string_literal: true

class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :service_type, null: false
      t.date :preferred_date, null: false
      t.string :preferred_time, null: false
      t.text :notes

      t.timestamps
    end
  end
end
