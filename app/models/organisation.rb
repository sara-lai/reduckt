class Organisation < ApplicationRecord

  # solution for two types of users
  belongs_to :owner, class_name: "User"
  has_many :employees, -> { where(role: "employee") }, class_name: "User"

  has_many :expenses

  validates :owner, presence: true

end
