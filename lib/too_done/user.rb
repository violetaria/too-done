module TooDone
  class User < ActiveRecord::Base
    has_many :sessions, :dependent => :destroy
    has_many :todo_lists, :dependent => :destroy


    def find_list(name)
      todo_list = self.todo_lists.find_by(name: name)
      if(todo_list.nil? || todo_list.tasks.count==0)
        puts "ERROR: #{self.name} does not have a \'#{name}\' list or the list has no tasks!"
        exit
      end
      todo_list
    end
  end

end
