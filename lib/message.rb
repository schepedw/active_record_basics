# == Schema Information
#
# Table name: messages
#
#  id                   :integer          not null, primary key
#  account_id           :integer          not null, indexed
#  shipment_id          :integer          indexed
#  status               :string(255)      not null, indexed
#  error                :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  recipient_contact_id :integer          not null, indexed
#  sender_contact_id    :integer          not null, indexed
#  raw_digest           :string(255)
#  subject              :text
#  text_part            :text
#  html_part            :text
#  template_variables   :text
#  message_type_id      :integer          not null, indexed
#  direction            :string(255)      not null
#  account_mailbox_id   :integer          indexed
#
# Indexes
#
#  fk__messages_account_id            (account_id)
#  fk__messages_account_mailbox_id    (account_mailbox_id)
#  fk__messages_message_type_id       (message_type_id)
#  fk__messages_recipient_contact_id  (recipient_contact_id)
#  fk__messages_sender_contact_id     (sender_contact_id)
#  fk__messages_shipment_id           (shipment_id)
#  index_messages_on_status           (status)
#

class Message < ActiveRecord::Base
  belongs_to :shipment
  has_many :message_recipients
  has_many :recipient_contacts,  :through => :message_recipients, :class_name => 'Contact'
  has_many :attachments, :through => :message_recipients
  validates_presence_of :body

end
