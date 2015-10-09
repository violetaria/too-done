class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do|t|
      t.integer   :todo_list_id,  null: false
      t.string    :name,          null: false
      t.date      :due_date,      null: true
      t.boolean   :complete,      null: false,   default: false
    end
  end

  def down
    drop_table :tasks
  end
end