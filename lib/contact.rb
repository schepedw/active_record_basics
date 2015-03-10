# == Schema Information
#
# Table name: contacts
#
#  id      :integer          not null, primary key
#  contact :string(255)      not null, indexed, indexed
#
# Indexes
#
#  index_contacts_on_contact        (contact) UNIQUE
#  index_contacts_on_lower_contact  (contact)
#

class Contact < ActiveRecord::Base
  validates :contact, :presence => true, :uniqueness => true

  def self.find_or_create_by_contact(contact)
    retry_count = 25
    begin
      where(:contact => contact).first_or_create!
    rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid, ActiveRecord::RecordNotUnique => error
      retry if( (retry_count -= 1) > 0 )
      raise error
    end
  end
end
