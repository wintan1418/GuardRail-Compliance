class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.references :document, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.string :channel
      t.string :status
      t.integer :days_before_expiry
      t.integer :escalation_level

      t.timestamps
    end
  end
end
