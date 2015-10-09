module TooDone
  class Tasks < ActiveRecord::Base
    belongs_to   :todo_list
  end
end