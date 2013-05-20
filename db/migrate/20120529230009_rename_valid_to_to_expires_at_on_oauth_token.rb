# -*- encoding : utf-8 -*-
class RenameValidToToExpiresAtOnOauthToken < ActiveRecord::Migration
  def self.up
    rename_column :oauth_tokens, :valid_to, :expires_at
  end

  def self.down
    rename_column :oauth_tokens, :expires_at, :valid_to
  end
end
