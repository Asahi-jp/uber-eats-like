class Order < ApplicationRecord
  has_many :line_foods

  validates :total_price, numericality: { greater_than: 0 }

  # 注文の保存、仮注文の論理削除と紐付け
  def save_with_update_line_foods!(line_foods)
    ActiveRecord::Base.transaction do
      line_foods.each do |line_food|
        line_food.update_attributes!(active: false, order: self)
      end
      self.save!
    end
  end
end