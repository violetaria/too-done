module TooDone
  class TodoLists < ActiveRecord::Base
    belongs_to :user
    has_many   :tasks
  end
end