class ChatMessage < ApplicationRecord
  belongs_to :user

  ROLES = %w[user assistant system].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :content, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :for_session, ->(session_id) { where(session_id: session_id) if session_id.present? }
end
