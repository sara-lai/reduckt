class Expense < ApplicationRecord
  belongs_to :organisation
  belongs_to :user

  has_many_attached :voice_notes
  has_many_attached :images
  has_many_attached :pdfs
end
