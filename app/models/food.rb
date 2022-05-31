class Food < ApplicationRecord
  belongs_to :restaurant
  has_one :line_food
end