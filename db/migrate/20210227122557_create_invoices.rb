class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.belongs_to :user
      t.string :pick_up_location
      t.integer :total_price
      t.string :driver_name
      t.string :booking_code, unique: true
      t.datetime :pick_up_at
      t.timestamps
    end
  end
end
