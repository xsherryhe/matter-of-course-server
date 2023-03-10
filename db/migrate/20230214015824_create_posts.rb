class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :postable, null: false, polymorphic: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
