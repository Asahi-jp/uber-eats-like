module Api
  module V1
    class LineFoodsController < ApplicationController
      before_action :set_food, only: %i[create replace]

      def index
        # アクティブな仮注文があれば一覧で出力
        line_foods = LineFood.active
        if line_foods.exists?
          render json: {
            line_food_ids: line_foods.map { |line_food| line_food.id },
            restaurant: line_foods.first.restaurant,
            count: line_foods.sum { |line_food| line_food.count },
            amount: line_foods.sum { |line_food| line_food.total_amount }
          }, status: :ok
        else
          render json: {}, status: :no_content
        end
      end

      def create
        # 他店舗での仮注文がある場合（例外）、早期リターン
        if LineFood.active.other_restaurant(@ordered_food.restaurant.id).exists?
          return render json: {
            existing_restaurant: LineFood.active.other_restaurant(@ordered_food.restaurant.id).first.restaurant.name,
            new_restaurant: @ordered_food.restaurant.name
          }, status: :not_acceptable
        end

        # 値をセット
        set_line_food(@ordered_food)

        # 保存処理
        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created
        else
          render json: {}, status: :internal_server_error
        end
      end

      def replace
        # 他店舗の仮注文を全て論理削除
        LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
          line_food.update_attribute(:active, false)
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created
        else
          render json: {}, status: :internal_server_error
        end
      end

      private

      def set_food
        @ordered_food = Food.find(params[:food_id])
      end

      # 仮注文が既に存在している場合は更新、存在しない場合は作成
      def set_line_food(ordered_food)
        if ordered_food.line_food.present?
          @line_food = ordered_food.line_food
          @line_food.attributes = {
            count: ordered_food.line_food.count + params[:count],
            active: true
          }
        else
          @line_food = ordered_food.build_line_food(
            count: params[:count],
            restaurant: ordered_food.restaurant,
            active: true
          )
        end
      end
    end
  end
end