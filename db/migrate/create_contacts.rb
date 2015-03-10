require_relative '../../environment'
class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts do |t|
      t.text :email, :index => :unique, :null => false
      t.timestamps
    end
  end

  def down
    drop_table :contacts
  end
end
CreateContacts.migrate(ARGV[0].to_sym)
