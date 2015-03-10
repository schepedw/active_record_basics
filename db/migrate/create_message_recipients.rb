require_relative '../../environment'
class CreateMessageRecipients < ActiveRecord::Migration
  def up
    create_table :message_recipients do |t|
      t.belongs_to :message, :null => false
      t.integer :recipient_id, :references => :contacts, :null => false
      t.timestamps
    end
  end

  def down
    drop_table :message_recipients
  end

  def change
    remove_column :message_recipients, :recipient_id
    add_column :message_recipients, :recipient_contact_id, :integer, :references => :contacts, :null => false
  end
end

CreateMessageRecipients.migrate(ARGV[0].to_sym)
