# == Schema Information
#
# Table name: delivery_attempts
#
#  id            :integer          not null, primary key
#  message_id    :integer          not null, indexed
#  shipper_id    :integer          indexed
#  status        :string(255)      not null
#  error_message :text
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  fk__delivery_attempts_message_id  (message_id)
#  fk__delivery_attempts_shipper_id  (shipper_id)
#

class DeliveryAttempt < ActiveRecord::Base
  belongs_to :message
  belongs_to :shipper

  validates_presence_of :message, :status
end
