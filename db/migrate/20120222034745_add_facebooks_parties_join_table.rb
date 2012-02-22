class AddFacebooksPartiesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :facebooks_parties, :id => false do |t|
      t.integer :facebook_id
      t.integer :party_id
    end
  end

  def self.down
    drop_table :facebooks_parties
  end
end
