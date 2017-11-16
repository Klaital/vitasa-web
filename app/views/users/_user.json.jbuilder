json.extract! user, :id, :name, :email, :phone, :certification, :sites_coordinated

json.work_history user.work_history
json.work_intents user.work_intents

json.roles user.roles.collect {|r| r.name}

json.suggestions user.suggestions
