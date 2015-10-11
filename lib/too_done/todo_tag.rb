module TooDone
  class TodoTag < ActiveRecord::Base
    belongs_to  :tag
    belongs_to  :task
  end
end