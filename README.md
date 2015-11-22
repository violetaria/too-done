# TooDone

A todo list tracking tool.  Supports mutliple users

## Usage

run with bundle! `bundle exec ruby lib/too_done.rb COMMAND`

Supported commands:

* too_done.rb add 'TASK'             # Add a TASK to a todo list.
* too_done.rb delete [LIST OR USER]  # Delete a todo list or a user.
* too_done.rb done                   # Mark a task as completed.
* too_done.rb edit                   # Edit a task from a todo list.
* too_done.rb help [COMMAND]         # Describe available commands or one specific command
* too_done.rb show                   # Show the tasks on a todo list in reverse order.
* too_done.rb switch USER            # Switch session to manage USER's todo lists.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/violetaria/too_done. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

