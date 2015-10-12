require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/todo_list"
require "too_done/task"
require "too_done/tag"
require "too_done/todo_tag"

require "thor"
require "pry"
require "date"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :tags, :aliases => :t, :type => :array,
      :desc => "A set of tag(s) which will be applied to the task.  Enter tags seperated by commas."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
      error_and_exit("ERROR: No user session.") unless Session.last
      error_and_exit("ERROR: Due Date must be in format YYYY-MM-DD") unless valid_date?(options[:date])
      todo_list = current_user.todo_lists.find_or_create_by(name: options[:list])
      todo_list.tasks.create(name: task, due_date: options[:date])
  #    options[:tags].each do |tag|
  #        current_user.tags.find_or_create_by(tag)
  #    end

    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      error_and_exit("ERROR: No user session.") unless Session.last
      open_tasks = invoke "show", [], :list => options[:list]
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
      error_and_exit("ERROR: No user session.") unless Session.last
      open_tasks = invoke "show", [], :list => options[:list]
      # TODO want to handle completing multiple tasks at the same time??
      if open_tasks.count==0
        puts "ERROR: No open tasks"
        exit
      end
      task = get_task(open_tasks)
      task.update(complete: true)
      puts "Task #{task.name} completed."
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :default => "history", :enum => ['history', 'overdue'],
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      error_and_exit("ERROR: No user session.") unless Session.last
      todo_list = current_user.todo_lists.find_by(name: options[:list])
      error_and_exit("ERROR: \'#{options[:list]}\' list not found or empty!") unless todo_list
      if options[:sort] == "overdue"
        tasks = todo_list.tasks.where(complete: options[:completed]).where("due_date < ?", DateTime.now).where.not(due_date: nil).order(id: :desc)
      else
        tasks = todo_list.tasks.where(complete: options[:completed]).order(id: :desc)
      end
      message = options[:completed] ? "Completed Tasks" : "Open Tasks"
      puts "#{todo_list.name} List => " + message + " [sorted by: " + options[:sort] + "]"
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
      error_and_exit("ERROR: No user session.") unless Session.last
      if(!options[:user].nil? && options[:list]!="*default*") || (options[:user].nil? && options[:list].nil?)
        puts "ERROR: Please specify either a list or a user, but not both!"
        exit
      end
      if(!options[:user].nil?)
        delete = User.find_by(name: options[:user])
        message = "user: #{options[:user]}"
      else
        ## TODO fix this, it currently deletes the list regardless of which user!!!!
        delete = current_user.todo_lists.find_by(name: options[:list])
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

=begin
    def show
      tasks = current_user.todo_lists.find_or_create_by(name: options[:list]).tasks
      return unless tasks
    end
=end

    private
    def current_user
      Session.last.user
    end

    def valid_date?(date)
      date.nil? || !(date =~ /^\d{4}-\d{2}-\d{2}$/.nil?)
    end

    def get_task(open_tasks)
      print "Choose task ID: "
      id = STDIN.gets.chomp
      task = open_tasks.find_by(id: id)
      until id =~ /^\d+$/ && !task.nil?
        puts "ERROR: ID not valid."
        print "Choose task ID: "
        id = STDIN.gets.chomp
        task = open_tasks.find_by(id: id)
      end
      task
    end

    def error_and_exit(text)
      puts text
      exit
    end

    def prompt_user(text,regex)
      print text
      input = STDIN.gets.chomp
      until input =~ regex
        print text
        input = STIN.gets.chomp
      end
      input
    end

  end
end

# binding.pry
TooDone::App.start(ARGV)
