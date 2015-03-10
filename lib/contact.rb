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
  validates :email, :presence => true, :uniqueness => true
end
