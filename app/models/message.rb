class Message < ApplicationRecord
  MAX_USER_MESSAGES = 10
  MAX_FILE_SIZE_MB = 10

  belongs_to :chat

  has_one_attached :file

  validate :file_size_limit
  validate :user_message_limit, if: -> { role == "user" }
  validates :content, length: { minimum: 10, maximum: 1000 }, if: -> { role == "user" }

  private

  def user_message_limit
    if chat.messages.where(role: "user").count >= MAX_USER_MESSAGES
      errors.add(:content, "You can only send #{MAX_USER_MESSAGES} messages per chat.")
    end
  end

  def file_size_limit
    if file.attached? && file.byte_size > MAX_FILE_SIZE_MB.megabytes
      errors.add(:file, "size must be less than #{MAX_FILE_SIZE_MB}MB")
    end
  end
end
