module TooDone
  class Tag < ActiveRecord::Base
    has_many    :todo_tags, :dependent  => :destroy
    has_many    :tasks, through: :todo_tags
  end
end