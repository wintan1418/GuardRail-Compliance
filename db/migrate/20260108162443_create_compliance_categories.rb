class CreateComplianceCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :compliance_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.string :color
      t.text :description

      t.timestamps
    end
  end
end
