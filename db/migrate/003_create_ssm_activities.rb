class CreateSsmActivities < ActiveRecord::Migration
  def change
    create_table :ssm_activities do |t|
      t.datetime :from
      t.datetime :to
      t.text     :note
      t.boolean  :offline
      t.boolean  :mobile

      t.string :project_ssm_id
      t.integer :employment_ssm_id

      t.integer :project_id
      t.integer :employment_id

      t.integer :issue_id
      t.integer :time_entry_id
      t.integer :user_id
    end

    add_index :ssm_activities, [:employment_id, :from, :to], unique: true
    add_index :ssm_activities, [:from, :to]
  end
end
