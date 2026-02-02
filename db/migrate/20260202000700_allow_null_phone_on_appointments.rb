class AllowNullPhoneOnAppointments < ActiveRecord::Migration[7.1]
  def change
    change_column_null :appointments, :phone, true
  end
end
