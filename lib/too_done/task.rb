module TooDone
  class Task < ActiveRecord::Base
    belongs_to   :todo_list
    has_many     :todo_tags,:dependent => :destroy
    has_many     :tags, through: :todo_tags

    # overwrites the to_s function so it prints out nicely
    def to_s
      "id: #{self.id} - name: #{self.name} - due by: #{self.due_date.nil? ? 'n/a' : self.due_date}"
    end


  end
end