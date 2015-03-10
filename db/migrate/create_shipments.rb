require_relative '../../environment'
class CreateShipments < ActiveRecord::Migration
  def up
    create_table :shipments do |t|
      t.string :from
      t.timestamps
    end
  end

  def down
    drop_table :shipments
  end

  def change
    add_column :shipments, :from, :string
  end
end

CreateShipments.migrate(ARGV[0].to_sym)
