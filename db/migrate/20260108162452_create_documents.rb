class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :compliance_category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.date :issue_date
      t.date :expiration_date
      t.string :status
      t.string :document_type
      t.string :issuing_authority
      t.string :reference_number
      t.boolean :auto_remind

      t.timestamps
    end
  end
end
