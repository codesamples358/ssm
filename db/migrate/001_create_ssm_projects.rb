class CreateSsmProjects < ActiveRecord::Migration
  def change
    create_table 'ssm_projects' do |t|
      t.string :ssm_id
      t.string :name
      t.string :color
      t.datetime :end_date
      t.string :client_id
    end

    add_index :ssm_projects, :name
    add_index :ssm_projects, :ssm_id
  end
end
