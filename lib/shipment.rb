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
  include AASM
  include Sidekiq::Apriori::Arb

  belongs_to  :account
  has_many    :messages
  has_many    :shipment_recipients
  has_many    :attachments, :through => :shipment_recipients
  has_many    :recipient_contacts, :through => :shipment_recipients
  belongs_to  :sender_contact, :class_name => 'Contact'
  lookup_for  :message_type, :symbolize => true if MessageType.table_exists?

  serialize :template_variables, JSON


  validates :account,       :presence => true
  validates :message_type,  :presence => true
  validates :recipients,    :presence => true
  validates :from,          :presence => true

  validate :check_template_variables
  validate :cron_has_valid_syntax

  before_save :save_cached_values
  before_create :process_messages

  after_save :update_attachments

  attr_accessor :global_tags, :from, :recipients

  aasm :column => 'status' do
    state :unprocessed, :initial => true
    state :queued
    state :completed,   :before_enter => :unset_job_identifier
    state :abandoned,   :before_enter => :unset_job_identifier

    event :enqueue do
      transitions :from => :unprocessed, :to => :queued
    end

    event :complete do
      transitions :from => [:unprocessed, :queued], :to => :completed
    end

    event :abandon do
      transitions :from => :queued, :to => :abandoned
    end
  end

  scope :needs_to_be_queued, ->(ago = 1.minute.ago ) { unprocessed.where(:job => nil).where(["created_at < ?", ago]) }

  def unset_job_identifier
    self.class.where(:id => self.id).update_all(:job => nil)
  end

  def from=(value)
    value = value.to_s if value.is_a?(Fixnum)
    raise ArgumentError, "expecting a String, received #{value.class.to_s}" unless value.is_a?(String) || value.is_a?(NilClass)
    attribute_will_change!('from') unless self.from == value
    @from = value
  end

  def from_changed?
    changed.include?('from')
  end

  def from
    if from_changed?
      @from
    else
      sender_contact.try(:contact)
    end
  end

  def recipients
    if recipients_changed?
      @recipients
    else
      self.recipient_contacts.map{ |ar| ar.contact }
    end
  end

  def recipients_changed?
    changed.include?('recipients')
  end

  def recipients=(recipient_list)
    case recipient_list
    when String
      recipient_list = [recipient_list]
    when NilClass
      []
    when Array
      # do nothing
    else
      raise ArgumentError, "expecting a String or Array, received #{recipient_list.class.to_s}"
    end

    attribute_will_change!('recipients') unless self.recipients == recipient_list
    @recipients = recipient_list
  end

  def global_variables=(vars)
    self.template_variables ||= {}
    self.template_variables['globals'] = vars
  end

  def global_variables
    self.template_variables.try(:fetch, 'globals', nil)
  end

  def template_variables_for(recipient)
    vars = self.template_variables.try(:fetch, recipient, nil)
    (global_variables || {}).merge(vars || {})
  end

  def attachments_for(recipient)
    attachments.select do |a|
      a.recipient_list.any? do |recip|
        recip == recipient ||
          recip ==  'globals'
      end
    end
  end

  def process_messages
    recipients.each do |recipient|
      message = messages.build(
        :account              => account,
        :from                 => from,
        :recipient            => recipient,
        :subject              => subject,
        :template_variables   => template_variables_for(recipient),
        :attachments          => attachments_for(recipient),
        :message_type         => message_type,
        :direction            => 'out'
      )

      if global_tags
        global_tags.each do |value|
          value = value.join ':' if value.kind_of? Array
          retry_count = 25
          begin
            Tag[value] # might have to create a Tag with race condition
          rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid, ActiveRecord::RecordNotUnique => error
            retry if( (retry_count -= 1) > 0 )
            raise error
          end

          message.tags << Tag[value] unless message.tags.include?(Tag[value])
        end
      end
    end

    messages
  end

  def add_attachments_to_messages
    messages.each do |message|
      message.attachments = attachments_for(message.recipient)
    end
  end

  def attachments=(new_val)
    @attachment_list = new_val
  end

  def attachments
    @attachment_list ||= super.reload
  end

  def now?
    schedule.nil? || schedule.now?
  end

  def at
    scheduled? ? schedule.next : Time.now
  end

  def scheduled?
    !!(schedule)
  end
  alias_method :successfully_parsed_cron?, :scheduled?

  def schedule
    return nil unless cron.present?
    @schedule   = nil if changed_attributes.keys.include?('cron')
    @schedule ||= Whedon::Schedule.new(cron)
  rescue Whedon::ParseError => err
    nil
  end

  def update_attachments
    attachments.each do |attachment|
      attachment.update(shipment_recipients: shipment_recipients.select do |recipient|
        attachment.recipient_list.include?('globals') ||
          attachment.recipient_list.include?(recipient.recipient_contact.contact)
      end
                       )
    end
  end

  private

  def save_cached_values
    if from_changed?
      self.sender_contact = Contact.find_or_create_by_contact(@from)
    end

    if recipients_changed?
      self.recipient_contacts.clear

      @recipients.each do |recipient|
        self.recipient_contacts << Contact.find_or_create_by_contact(recipient)
      end
    end
  end

  def check_template_variables
    errors.add(:template_variables, "are invalid") if variable_format_invalid?
  end


  def variable_format_invalid?
    return false if template_variables.nil?

    return true unless template_variables.is_a?(Hash) &&
      no_hidden_recipients( template_variables.keys)

    return true unless template_variables.values.all? do |file_description|
      file_description.is_a?(Hash) &&
        file_description.values.all?{ |v| v.is_a?(String)}
    end

    false
  end



  def no_hidden_recipients(recipient_list)
    recipients | recipient_list == recipients | ['globals']
  end

  def cron_has_valid_syntax
    valid = cron.nil? || successfully_parsed_cron?
    errors.add(:cron, "has invalid cron syntax") unless valid
  end

  prioritize do
    self.priority = nil unless Sidekiq::Apriori::PRIORITIES.include?(self.priority)

    if message_type == :sms || template =~ /sms_/
      self.priority ||= 'immediate'
    else
      ## Attempt to deduce self.priority from template
      self.priority ||= 
        case self.template
        when /reset_/
          'immediate'
        when /ast_/, 'arbitrary_html_content'
          'high'
        when /in_default|pmt_plan/
          'low'
        else
          nil
        end
    end
  end

end
