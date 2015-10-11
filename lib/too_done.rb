require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/todo_list"
require "too_done/task"

require "thor"
require "pry"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
      if(current_user.nil?)
        ## TODO - make a function to check and deal with no current user (aka, blank db)
      end
      if !options[:date].nil? && (options[:date] =~ /^\d{4}-\d{2}-\d{2}$/).nil?
        puts "ERROR: Due Date must be in format YYYY-MM-DD"
        exit
      end
      todo_list = current_user.todo_lists.find_or_create_by(name: options[:list])
      todo_list.tasks.create(name: task, due_date: options[:date])
      ## TODO make sure to validate that tasks are > 5 characters + start with a character
      ## TODO make sure date is in the right format
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      ## TODO Check nil current user
      todo_list = find_list(options[:list])
      # print stuff
      puts "Open tasks:"
      open_tasks = todo_list.tasks.where(complete: false)
      open_tasks.each do |task|
        puts "#{task}"
      end
      task = get_task(open_tasks)
      puts "Enter a new title: "
      ## TODO make sure title is not nil?
      title = STDIN.gets.chomp
      puts "Enter a new due date: "
      ## TODO check valid dates
      due_date = STDIN.gets.chomp
      task.name = title
      task.due_date = due_date
      task.save
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      # find the right todo list
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one(s?) to mark done
      binding.pry
      todo_list = find_list(options[:list])
      puts "Open tasks:"
      open_tasks = todo_list.tasks.where(complete: false)
      open_tasks.each do |task|
        puts "#{task}"
      end
      # TODO want to handle completing multiple tasks at the same time??
      task = get_task(open_tasks)
      task.complete = true
      task.save
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
      # find or create the right todo list
      # show the tasks ordered as requested, default to reverse order (recently entered first)
      todo_list = find_list(options[:list])
      if options[:sort] == "history"
        tasks = todo_list.tasks.where(complete: options[:completed]).order(id: :desc)
      else
        tasks = todo_list.tasks.where(complete: options[:completed]).where.not(due_date: nil).order(id: :desc)
      end
      tasks.each do |task|
        puts "#{task}"
        binding.pry
      end

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

    def get_task(open_tasks)
      print "Choose task ID to mark completed: "
      id = STDIN.gets.chomp
      task = open_tasks.find_by(id: id)
      until id =~ /^\d$/ && !task.nil?
        puts "ERROR: ID not valid."
        print "Pick an ID to edit: "
        id = STDIN.gets.chomp
        task = open_tasks.find_by(id: id)
      end
      task
    end
  end
end

# binding.pry
TooDone::App.start(ARGV)
