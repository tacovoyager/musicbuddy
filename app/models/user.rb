class User < ApplicationRecord
  has_one :spotify_account, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

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

  def spotify_account_from_omniauth(auth)
    account = spotify_account || build_spotify_account
    account.update!(
      uid: auth.uid,
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: auth.credentials.expires_at && Time.at(auth.credentials.expires_at),
      scope: auth.credentials.scope
    )
    account
  end
end
