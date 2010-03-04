# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100304222305) do

  create_table "scope_inputs", :force => true do |t|
    t.string  "circuit", :limit => 50, :null => false
    t.float   "time",                  :null => false
    t.float   "voltage",               :null => false
    t.string  "energy",  :limit => 50
    t.integer "pixel"
    t.string  "scan",    :limit => 50
    t.float   "x"
    t.float   "y"
  end

  add_index "scope_inputs", ["circuit"], :name => "index_scope_inputs_circuit"
  add_index "scope_inputs", ["time"], :name => "index_scope_inputs_time"
  add_index "scope_inputs", ["voltage"], :name => "index_scope_inputs_voltage"

end
