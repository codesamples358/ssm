class CreateSsmEmployments < ActiveRecord::Migration
  def change
    create_table :ssm_employments do |t|
      t.integer :ssm_id
      t.string :name
      t.string :email
      t.boolean :registered
      t.datetime :last_active
      t.boolean :can_edit
      t.decimal :pay_rate
      t.datetime :end_date
      t.boolean :in_pause
      t.integer :role

      t.integer :user_id
    end

    add_index :ssm_employments, :ssm_id
    add_index :ssm_employments, :email
  end
end
