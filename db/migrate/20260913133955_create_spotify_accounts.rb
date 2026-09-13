class CreateSpotifyAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :spotify_accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :uid, null: false
      t.string :access_token, null: false
      t.string :refresh_token
      t.datetime :expires_at
      t.string :scope
      t.string :token_type

      t.timestamps
    end

    add_index :spotify_accounts, :uid, unique: true
  end
end
