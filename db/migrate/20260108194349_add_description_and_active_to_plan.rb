class AddDescriptionAndActiveToPlan < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :description, :text
    add_column :plans, :active, :boolean
  end
end
