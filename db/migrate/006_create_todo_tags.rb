class CreateTodoTags < ActiveRecord::Migration
  def up
    create_table :todo_tags do|t|
      t.integer    :tag_id,     null: false
      t.integer    :task_id,    null: false
    end
  end

  def down
    drop_table :todo_tags
  end
end