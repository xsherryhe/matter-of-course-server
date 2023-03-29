class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.references :videoable, polymorphic: true
      t.timestamps
    end
  end
end
