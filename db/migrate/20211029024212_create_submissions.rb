class CreateSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :submissions do |t|
      t.string :title
      t.integer :price
      t.string :stripe_payment_id
      t.string :string
      t.string :status

      t.timestamps
    end
  end
end
