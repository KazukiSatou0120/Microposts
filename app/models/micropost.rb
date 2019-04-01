class Micropost < ApplicationRecord
  belongs_to :user
  #validate=検証　presence=存在する
  validates :content, presence: true, length: { maximum: 255 }
end