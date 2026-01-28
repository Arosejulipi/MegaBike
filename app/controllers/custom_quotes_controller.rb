# frozen_string_literal: true

class CustomQuotesController < ApplicationController
  def new
    @custom_quote = CustomQuote.new
  end

  def create
    @custom_quote = CustomQuote.new(custom_quote_params)
    if @custom_quote.save
      OwnerMailer.custom_quote_request(@custom_quote).deliver_later
      redirect_to root_path, notice: "¡Genial! Recibimos tu pedido de presupuesto y lo enviamos a Mega Bike."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def custom_quote_params
    params.require(:custom_quote).permit(:full_name, :email, :phone, :bike_type, :frame_size, :color, :brakes, :gears, :budget_range, :extra_notes)
  end
end
