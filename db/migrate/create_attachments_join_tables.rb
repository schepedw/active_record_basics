require_relative '../../environment'
class AddAttachmentsJoinTables < ActiveRecord::Migration
  def up
    create_table :attachments_message_recipients do |t|
      t.belongs_to :message_recipient, index: true
      t.belongs_to :attachment        , index: true
      t.timestamps
    end
  end

  def down
    drop_table :attachments_message_recipients
  end
end

AddAttachmentsJoinTables.migrate(ARGV[0].to_sym)
