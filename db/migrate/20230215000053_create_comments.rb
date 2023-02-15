class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :reactable, null: false, polymorphic: true
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
