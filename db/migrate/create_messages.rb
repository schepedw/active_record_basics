require_relative '../../environment'
class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.belongs_to :shipment
      t.text :body
    end
  end

  def down
    drop_table :messages
  end
end

CreateMessages.migrate(ARGV[0].to_sym)
