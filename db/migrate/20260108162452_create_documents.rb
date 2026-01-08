class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :compliance_category, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description
      t.date :issue_date
      t.date :expiration_date
      t.string :status, default: 'active'
      t.string :document_type
      t.string :issuing_authority
      t.string :reference_number
      t.integer :reminder_days, array: true, default: [90, 60, 30, 7]
      t.boolean :auto_remind, default: true

      t.timestamps
    end

    add_index :documents, [:organization_id, :status]
    add_index :documents, :expiration_date
  end
end

