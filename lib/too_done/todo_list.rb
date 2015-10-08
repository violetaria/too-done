module TooDone
  class TodoList < ActiveRecord::Base
    belongs_to :user
  end
end