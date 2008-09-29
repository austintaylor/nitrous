class CreateChickens < ActiveRecord::Migration
  def self.up
    create_table :chickens do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :chickens
  end
end
