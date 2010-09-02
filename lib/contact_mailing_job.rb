class ContactMailingJob < Struct.new(:contact)
  def perform
    UserNotifier.deliver_contact_redu(contact)
  end
end