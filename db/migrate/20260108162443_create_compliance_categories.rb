class CreateComplianceCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :compliance_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, default: '#1E293B'
      t.text :description
      t.integer :default_reminder_days, array: true, default: [90, 60, 30, 7]

      t.timestamps
    end
  end
end

