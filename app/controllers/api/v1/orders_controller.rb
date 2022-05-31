module Api
  module V1
    class OrdersController < ApplicationController
      def create
        # 複数の仮注文
        posted_line_foods = LineFood.where(id: params[:line_food_ids])
        order = Order.new(
          total_price: total_price(posted_line_foods),
        )
        if order.save_with_update_line_foods!(posted_line_foods)
          render json: {}, status: :no_content
        else
          render json: {}, status: :internal_server_error
        end
      end

      private

      # 仮注文の総計の総計＋店舗手数料
      def total_price(posted_line_foods)
        posted_line_foods.sum {|line_food| line_food.total_amount } + posted_line_foods.first.restaurant.fee
      end
    end
  end
end