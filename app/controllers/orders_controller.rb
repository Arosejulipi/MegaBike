# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :require_login
  before_action :block_admin_purchases

  def new
    @items = cart_items
    if @items.empty?
      redirect_to products_path, alert: "Tu carrito está vacío."
    end
  end

  def create
    items = cart_items
    if items.empty?
      redirect_to products_path, alert: "Tu carrito está vacío."
      return
    end

    order = current_user.orders.create!(status: "pending")

    items.each do |item|
      order.order_items.create!(product: item.product, quantity: item.quantity, unit_price: item.product.price)
    end

    session[:cart] = {}

    redirect_to order_path(order), notice: "¡Compra registrada! Te contactaremos para coordinar pago y retiro."
  end

  def show
    @order = current_user.orders.find(params[:id])
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
