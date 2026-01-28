# frozen_string_literal: true

class ProductsController < ApplicationController
  def index
    @products = Product.available.order(:name)
  end

  def show
    @product = Product.find(params[:id])
  end
end
