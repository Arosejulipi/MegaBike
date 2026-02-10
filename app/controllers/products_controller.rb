# frozen_string_literal: true

class ProductsController < ApplicationController
  def index
    base = Product.available

    @brands = base.where.not(brand: [nil, ""]).distinct.order(:brand).pluck(:brand)
    @categories = base.where.not(category: [nil, ""]).distinct.order(:category).pluck(:category)

    q = params[:q].to_s.strip
    brand = params[:brand].to_s.strip
    category = params[:category].to_s.strip
    min_price = params[:min_price].to_s.strip
    max_price = params[:max_price].to_s.strip
    sort = params[:sort].to_s.strip

    @products = base
    if q != ""
      qd = q.downcase
      like = "%#{qd}%"
      @products = @products.where(
        "lower(name) LIKE ? OR coalesce(lower(description), '') LIKE ?",
        like,
        like
      )
    end
    @products = @products.where(brand: brand) if brand != ""
    @products = @products.where(category: category) if category != ""

    min_val = Float(min_price, exception: false)
    max_val = Float(max_price, exception: false)
    @products = @products.where("price >= ?", min_val) if min_val
    @products = @products.where("price <= ?", max_val) if max_val

    @products =
      case sort
      when "price_asc" then @products.order(price: :asc)
      when "price_desc" then @products.order(price: :desc)
      else
        @products.order(:name)
      end
  end

  def show
    @product = Product.find(params[:id])
  end
end
