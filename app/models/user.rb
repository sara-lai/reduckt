class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :role, inclusion: [ "owner", "employee" ]

  belongs_to :organisation, optional: :true

  def invitation_status
    if invitation_accepted_at.present?
      "accepted"
    elsif invitation_sent_at.present?
      "pending"
    else
      "na"
    end
  end

end
