require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/todo_list"
require "too_done/task"

require "thor"
require "pry"
require "date"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
      check_for_user
      if !valid_date?(options[:date])
        puts "ERROR: Due Date must be in format YYYY-MM-DD"
        exit
      end
      todo_list = current_user.todo_lists.find_or_create_by(name: options[:list])
      todo_list.tasks.create(name: task, due_date: options[:date])
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      check_for_user
      todo_list = find_list(options[:list])

      puts "Open tasks:"
      open_tasks = todo_list.tasks.where(complete: false)
      open_tasks.each do |task|
        puts task
      end
      task = get_task(open_tasks)
      print "Enter a new title: "
      title = STDIN.gets.chomp
      while title.nil?
        puts "ERROR: Title cannot be blank"
        print "Enter a new title: "
        title = STDIN.gets.chomp
      end
      print "Enter a new due date: "
      due_date = STDIN.gets.chomp
      until valid_date?(due_date)
        puts "ERROR: Due Date must be in format YYYY-MM-DD"
        print "Enter a new due date: "
        due_date = STDIN.gets.chomp
      end
      task.update(name: title, due_date: due_date)
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      check_for_user
      puts "Open tasks:"
      open_tasks = invoke "show", :list => options[:list]
      # TODO want to handle completing multiple tasks at the same time??
      task = get_task(open_tasks)
      task.update(complete: true)
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'],
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      todo_list = find_list(options[:list])
      if options[:sort] == "overdue"
        tasks = todo_list.tasks.where(complete: options[:completed]).where.not(due_date: nil).order(id: :desc)
      else
        tasks = todo_list.tasks.where(complete: options[:completed]).order(id: :desc)
      end
      tasks.each do |task|
        puts task
      end
      tasks
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      # BAIL if both list and user options are provided
      # BAIL if neither list or user option is provided
      # find the matching user or list
      # BAIL if the user or list couldn't be found
      # delete them (and any dependents)
      if(!options[:user].nil? && options[:list]!="*default*") || (options[:user].nil? && options[:list].nil?)
        puts "ERROR: Please specify either a list or a user, but not both!"
        exit
      end
      check_for_user
      if(!options[:user].nil?)
        delete = User.find_by(name: options[:user])
        message = "user: #{options[:user]}"
      else
        delete = TodoList.find_by(name: options[:list])
        message = "list: #{options[:list]}"
      end
      if(delete.nil?)
        puts "ERROR: #{message} not found"
        exit
      end
      delete.destroy
      puts "Deletion of #{message} completed."
    end

    desc "switch USER", "Switch session to manage USER's todo lists."
    def switch(username)
      user = User.find_or_create_by(name: username)
      user.sessions.create
    end

    private
    def current_user
      Session.last.user
    end

    def find_list(name)
      todo_list = current_user.todo_lists.find_by(name: name)
      if(todo_list.nil? || todo_list.tasks.count==0)
        puts "ERROR: #{current_user.name} does not have a #{name} list or it has no tasks!"
        exit
      end
      todo_list
    end

    def check_for_user
      if(current_user.nil?)
        puts "ERROR: No users loaded. Please use the SWITCH command to add a user"
        exit
      end
    end

    def valid_date?(date)
      date.nil? || !(date =~ /^\d{4}-\d{2}-\d{2}$/.nil?)
    end

    def get_task(open_tasks)
      print "Choose task ID: "
      id = STDIN.gets.chomp
      task = open_tasks.find_by(id: id)
      until id =~ /^\d+$/ && !task.nil?
        binding.pry
        puts "ERROR: ID not valid."
        print "Choose task ID: "
        id = STDIN.gets.chomp
        task = open_tasks.find_by(id: id)
      end
      task
    end
  end
end

# binding.pry
TooDone::App.start(ARGV)
