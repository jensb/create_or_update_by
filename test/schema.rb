ActiveRecord::Schema.define(:version => 0) do
  create_table :coub_test, :force => true do |t|
    t.string :name
    t.integer :counter
    t.float :weight
    t.decimal :price
    t.datetime :last_poop
    t.timestamp :created_at, :updated_at
  end
end