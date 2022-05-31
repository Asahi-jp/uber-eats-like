class LineFood < ApplicationRecord
  belongs_to :restaurant
  belongs_to :food
  belongs_to :order, optional: true

  validates :count, numericality: { greater_than: 0 }

  # アクティブかどうか
  scope :active, -> { where(active: true) }
  # 他店舗
  scope :other_restaurant, -> (picked_restaurant_id) { where.not(restaurant_id: picked_restaurant_id) }

  # 仮注文の総計（商品価格×商品数）
  def total_amount
    food.price * count
  end
end