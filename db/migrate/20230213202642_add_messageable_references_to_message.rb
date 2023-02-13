class AddMessageableReferencesToMessage < ActiveRecord::Migration[7.0]
  def change
    add_reference :messages, :messageable, null: true, polymorphic: true
  end
end
