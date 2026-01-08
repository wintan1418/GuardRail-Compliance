class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :stripe_price_id
      t.integer :price_cents
      t.string :interval
      t.integer :max_users
      t.integer :max_documents
      t.boolean :sms_enabled
      t.boolean :slack_enabled
      t.jsonb :features

      t.timestamps
    end
  end
end
