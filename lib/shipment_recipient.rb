# == Schema Information
#
# Table name: shipment_recipients
#
#  id                   :integer          not null, primary key
#  shipment_id          :integer          not null, indexed
#  recipient_contact_id :integer          not null, indexed, indexed
#
# Indexes
#
#  fk__shipment_recipients_recipient_contact_id  (recipient_contact_id)
#  fk__shipment_recipients_recipient_id          (recipient_contact_id)
#  fk__shipment_recipients_shipment_id           (shipment_id)
#

class ShipmentRecipient < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :recipient_contact, :class_name => 'Contact'
  has_and_belongs_to_many :attachments
end
