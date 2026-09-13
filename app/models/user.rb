class User < ApplicationRecord
  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid).tap do |user|
      user.update!(
        email: auth.info.email,
        name: auth.info.name,
        avatar_url: auth.info.image
      )
    end
  end
end
