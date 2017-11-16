json.extract! user, :id, :name, :email, :phone, :certification, :sites_coordinated

json.work_history work_history
json.work_intents work_intents

json.roles user.roles.collect {|r| r.name}

json.suggestions suggestions
