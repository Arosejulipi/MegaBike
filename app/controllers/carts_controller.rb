# frozen_string_literal: true

class CartsController < ApplicationController
  def show
    @cart = cart
    @items = cart_items
  end

  def add_item
    pid = params[:product_id].to_s
    qty = params[:quantity].to_i
    qty = 1 if qty < 1

    cart[pid] = (cart[pid] || 0) + qty
    session[:cart] = cart

    redirect_back fallback_location: products_path, notice: "Producto agregado al carrito."
  end

  def remove_item
    pid = params[:product_id].to_s
    cart.delete(pid)
    session[:cart] = cart
    redirect_to cart_path, notice: "Producto quitado del carrito."
  end

  def clear
    session[:cart] = {}
    redirect_to cart_path, notice: "Carrito vaciado."
  end

  private

  def cart
    session[:cart] ||= {}
  end

  def cart_items
    products = Product.where(id: cart.keys)
    products.map do |p|
      OpenStruct.new(product: p, quantity: cart[p.id.to_s].to_i)
    end
  end
end
