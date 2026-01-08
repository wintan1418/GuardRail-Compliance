class CreateNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_settings do |t|
      t.references :organization, null: false, foreign_key: true
      t.boolean :email_enabled
      t.string :email_from_name
      t.boolean :sms_enabled
      t.string :twilio_phone_number
      t.boolean :slack_enabled
      t.string :slack_webhook_url
      t.string :slack_channel
      t.boolean :escalation_enabled
      t.integer :escalation_after_days

      t.timestamps
    end
  end
end
