class Attachment < ActiveRecord::Base
  validates_presence_of :content
  validates_presence_of :file_type
  validates_presence_of :filename
  has_and_belongs_to_many :message_recipients, :through => :attachments_message_recipients
  has_many :recipient_contacts, :through => :message_recipients
  has_many :messages, :through => :message_recipients
end
