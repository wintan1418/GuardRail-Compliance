class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.string :resource_type
      t.bigint :resource_id
      t.jsonb :metadata
      t.inet :ip_address

      t.timestamps
    end
  end
end
