# frozen_string_literal: true

module Admin
  class ProductsController < ApplicationController
    before_action :require_admin
    before_action :set_product, only: %i[show edit update destroy]

    def index
      @products = Product.order(created_at: :desc)
    end

    def show; end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_product_path(@product), notice: "Producto creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "Producto actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Producto eliminado."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :stock, :active, :image_url, :brand, :category)
    end
  end
end
