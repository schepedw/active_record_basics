require_relative '../../environment'
class CreateAttachments < ActiveRecord::Migration
  def up
    create_table :attachments do |t|
      t.string :content, :null => false
      t.string :file_type, :null => false
      t.string :filename, :null => false
      t.timestamps
    end
  end

  def down
    drop_table :attachments
  end
end

CreateAttachments.migrate(ARGV[0].to_sym)
