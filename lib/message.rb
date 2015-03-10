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
  include AASM

  belongs_to :account
  belongs_to :shipment
  belongs_to :account_mailbox
  belongs_to :recipient_contact,    :class_name => 'Contact'
  belongs_to :sender_contact,       :class_name => 'Contact'
  has_many   :postbacks,         :inverse_of => :message
  has_many   :delivery_attempts, :inverse_of => :message
  lookup_for :message_type, :symbolize => true

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :attachments

  serialize :template_variables, JSON

  validates :account,      :presence => true
  validates :from,         :presence => true
  validates :recipient,    :presence => true
  validates :message_type, :presence => true
  validates :direction,    :presence => true, :inclusion => ['in', 'out']
  validates :status,       :presence => true, :inclusion => ['queued', 'failed', 'sent', 'received', 'incoming', 'bccd']

  validate :check_template_variables

  before_create :default_initial_status
  before_save :save_cached_values

  aasm :column => 'status' do
    state :queued, :initial => true
    state :failed
    state :sent
    state :received
    state :incoming
    state :bccd

    event :mark_failed do
      transitions :from => :queued, :to => :failed
    end

    event :mark_sent do
      transitions :from => [:queued, :failed], :to => :sent
    end
  end

  def mark(result)
    return unless result.to_s.present?
    self.send("mark_#{result.to_s}!") rescue nil
  end

  scope :outgoing, -> { where(direction: 'out') }

  scope :updated_after, ->(ago) { where(["updated_at > ?", ago]) }
  scope :recent_fails,  ->(ago = 12.hour.ago) { failed.outgoing.updated_after(ago) }

  def self.tagged_with_all(tags_list)
    tags_list = [tags_list] if tags_list.is_a?(String)
    raise ArgumentError, "expecting an Array" unless tags_list.is_a?(Array)

    joins(:tags).where('tags.value IN (?)', tags_list)
      .group('messages.id').having('COUNT(*) >= ?', tags_list.size)
  end

  def from=(value)
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

  def recipient=(value)
    attribute_will_change!('recipient') unless self.recipient == value
    @recipient = value
  end

  def recipient_changed?
    changed.include?('recipient')
  end

  def recipient
    if recipient_changed?
      @recipient
    else
      recipient_contact.try(:contact)
    end
  end

  def raw
    if @raw.nil?
      return nil if self.raw_digest.nil?
      if self.raw_digest.length == 64
        blob_path = File.join(AppConfig.blob_store.email_bucket, self.raw_digest)
      else
        blob_path = self.raw_digest
      end
      @raw = BlobStore.get(blob_path)
    end
    @raw
  end

  def raw_changed?
    changed.include?('raw')
  end

  def raw=(new_raw)
    attribute_will_change!('raw') unless self.raw == new_raw
    @raw = new_raw
  end

  def attachments
    return super unless super.empty? 
    if message_type == :email && raw
      mail = Mail.read_from_string(raw)
      return mail.attachments
    end
    []
  end

  def keywords
    Keyword.for_account(account).matching(self.text_part)
  end

  def has_keyword?
    keywords.count > 0
  end

  def keyword
    keywords.order(:id).last
  end

  def has_valid_keyword_syntax?
    keyword.try(:validates_syntax_of?, self.text_part)
  end

  private

  def default_initial_status
    return unless new_record?
    self.status ||= 'received' if self.direction == 'in'
    self.status ||= 'queued'   if self.direction == 'out'
  end

  def save_cached_values
    if from_changed?
      self.sender_contact = Contact.find_or_create_by_contact(@from)
    end

    if recipient_changed?
      self.recipient_contact = Contact.find_or_create_by_contact(@recipient)
    end

    if raw_changed?
      hexdigest = OpenSSL::Digest::SHA256.hexdigest(@raw)
      new_blob_path = File.join(AppConfig.blob_store.email_bucket, hexdigest)
      BlobStore.put(contents: @raw, filepath: new_blob_path)
      self.raw_digest = hexdigest
    end
  end

  def check_template_variables
    errors.add(:template_variables, "are invalid") if variable_format_invalid?(template_variables)
  end


  def variable_format_invalid?(variable)
    return false if variable.nil?
    return true unless variable.is_a?(Hash)
    return true unless variable.values.all?{ |v| v.is_a?(String)}
    false
  end
end
