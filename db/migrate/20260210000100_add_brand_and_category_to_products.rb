# frozen_string_literal: true

class AddBrandAndCategoryToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :brand, :string
    add_column :products, :category, :string
    add_index :products, :brand
    add_index :products, :category
  end
end

