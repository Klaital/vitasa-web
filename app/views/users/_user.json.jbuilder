json.extract! user, :id, :name, :email, :phone, :certification, :sites_coordinated

json.array! user.work_history, partial: 'signups/signup'
json.array! user.work_intents, partial: 'signups/signup'

json.roles user.roles.collect {|r| r.name}

json.suggestions user.suggestions
