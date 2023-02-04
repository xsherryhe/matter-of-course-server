class CreateInstructionInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :instruction_invitations do |t|
      t.integer :response
      t.references :course, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
