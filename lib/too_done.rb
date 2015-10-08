LOGGING = true

require "too_done/version"
require "too_done/init_db"
# require "too_done/models"

require "thor"
require "pry"

module TooDone
  class App < Thor

    desc "add 'TASK DESCRIPTION'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
    end

    desc "edit", "Choose a task to edit from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
    end

    desc "show", "Show the tasks on a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s,
      :desc => "Optional sorting by 'history' (chronological, showing completed) or 'overdue'. Limits results to those with a due date."
    def show
    end

    desc "delete LIST_OR_USER", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
    end

    desc "switch USER", "Switch session to manage USER's todo lists."
    def switch(username)
    end
  end
end

TooDone::App.start(ARGV)
