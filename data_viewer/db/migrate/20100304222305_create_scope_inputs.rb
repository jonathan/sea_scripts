class CreateScopeInputs < ActiveRecord::Migration
  def self.up
    create_table :scope_inputs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :scope_inputs
  end
end
