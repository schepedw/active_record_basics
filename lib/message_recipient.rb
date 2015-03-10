# == Schema Information
#
# Table name: shipment_recipients
#
#  id                   :integer          not null, primary key
#  message_id           :integer          not null, indexed
#  recipient_contact_id :integer          not null, indexed, indexed
#
#

class MessageRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :recipient_contact, :class_name => 'Contact'
  has_and_belongs_to_many :attachments
end
