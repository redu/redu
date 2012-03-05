#define callback models
module Invitee
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Callbacks
    define_callbacks :invitation_accepted
  end

  module ClassMethods
    def after_invitation_accepted(*args, &block)
      set_callback(:invitation_accepted, :after, *args, &block)
    end

    def before_invitation_accepted(*args, &block)
      set_callback(:invitation_accepted, *args, &block)
    end
  end

  def accept_invitation!(new_user)
    run_callbacks(:invitation_accepted) do
      puts "#{self}\n"
      #TODO: associar new user a instancia
      #TODO: remover entrada de invitation (invitiation aceita)
      puts "2\n"
    end
  end

end

#open associations classes
class Friendship < ActiveRecord::Base
  include Invitee

  after_invitation_accepted do
    puts "#{self}\n"
    #TODO: criacao de friendship
    puts "1\n"
  end
end

class Invitation < ActiveRecord::Base

  validates_presence_of :email, :invitable_id, :invitable_type
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/

  belongs_to :invitable, :polymorphic => true

  after_validation :generate_token, :on => :create

  def accept!(new_user)
    puts @invitable
    @invitable.accept_invitation!(new_user)
  end

  protected
  def generate_token
    self.token = ActiveSupport::SecureRandom.base64(8).gsub("/","_").
      gsub(/=+$/,"")
  end
end
