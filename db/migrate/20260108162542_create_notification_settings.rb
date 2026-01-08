class CreateNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_settings do |t|
      t.references :organization, null: false, foreign_key: true
      t.boolean :email_enabled, default: true
      t.string :email_from_name
      t.boolean :sms_enabled, default: false
      t.string :twilio_phone_number
      t.boolean :slack_enabled, default: false
      t.string :slack_webhook_url
      t.string :slack_channel
      t.integer :reminder_intervals, array: true, default: [90, 60, 30, 7]
      t.boolean :escalation_enabled, default: true
      t.integer :escalation_after_days, default: 3

      t.timestamps
    end
  end
end

