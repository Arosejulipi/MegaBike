# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @featured_products = Product.available.limit(6)
  end

  def about; end
end
