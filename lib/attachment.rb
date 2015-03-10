#  Table name: attachments
#
#  id                   :integer          not null, primary key
#  content_digest       :string(255)
#  content_type         :string(255)
#  filename             :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
class Attachment < ActiveRecord::Base
  before_validation :content_digest
  has_and_belongs_to_many :messages
  has_and_belongs_to_many :shipment_recipients, :through => :attachments_shipment_recipients
  has_many :recipient_contacts, :through => :shipment_recipients

  validates :content_digest,      :presence => true
  validates :content_type,        :presence => true
  validates :filename,            :presence => true
  validate :store_blob

  def as_json(*)
    {
      "id"                => self.id,
      "filename"          => self.filename,
      "content_type"      => self.content_type
    }
  end

  def base64=(new_val)
    errors.add(:content, 'base64 cannot be nil') and return if new_val.nil?
    @content = Base64.decode64(new_val)
  end

  def base64
    Base64.encode64(content)
  end

  def content
    if @content.nil?
      return nil if self.content_digest.nil?
      blob_path = File.join(AppConfig.blob_store.attachment_bucket, self.content_digest)
      @content= BlobStore.get(blob_path)
    end
    @content
  end

  def content_digest
    if @content.nil?
      errors.add(:content, 'content not found') and return if super.nil?
      return super
    end
    self.content_digest = OpenSSL::Digest::SHA256.hexdigest(@content)
  end

  def recipient_list=(new_val)
    @recipient_list = new_val
  end

  def recipient_list
    @recipient_list ||= recipient_contacts.map{ |a| a.contact}
  end

  private

  def store_blob
    begin
      new_blob_path = File.join(AppConfig.blob_store.attachment_bucket, self.content_digest)
      BlobStore.put(contents: @content, filepath: new_blob_path)
    rescue StandardError => e
      errors.add(:content, "#{e.message}\n#{e.inspect}")
      return nil
    end
  end

  def attachment_bucket_name
    @email_bucket_name ||= AppConfig.blob_store.attachment_bucket
  end

end
