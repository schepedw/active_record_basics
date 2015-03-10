# == Schema Information
#
# Table name: shipments
#
#  id                 :integer          not null, primary key
#  account_id         :integer          not null, indexed, indexed => [message_type_id, template, cron, priority]
#  template           :string(255)      indexed => [account_id, message_type_id, cron, priority]
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  subject            :text
#  sender_contact_id  :integer          not null, indexed, indexed
#  text_part          :text
#  html_part          :text
#  template_variables :text
#  message_type_id    :integer          not null, indexed, indexed => [account_id, template, cron, priority]
#  status             :string(255)      indexed
#  cron               :string(255)      indexed => [account_id, message_type_id, template, priority]
#  priority           :string(255)      indexed => [account_id, message_type_id, template, cron]
#  job                :string(255)
#
# Indexes
#
#  fk__shipments_account_id                (account_id)
#  fk__shipments_from_id                   (sender_contact_id)
#  fk__shipments_message_type_id           (message_type_id)
#  fk__shipments_sender_contact_id         (sender_contact_id)
#  index_shipments_for_shipment_processor  (account_id,message_type_id,template,cron,priority)
#  index_shipments_on_status               (status)

class Shipment < ActiveRecord::Base

  has_many    :messages
  has_many    :attachments, :through => :messages
  has_many    :recipient_contacts, :through => :messages

  validates :from,          :presence => true
end
