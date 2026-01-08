class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :slug
      t.string :industry
      t.string :phone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.integer :compliance_health_score

      t.timestamps
    end
    add_index :organizations, :slug
  end
end
