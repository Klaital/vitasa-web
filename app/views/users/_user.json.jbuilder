json.extract! user, :id, :name, :email, :phone, :certification, :sites_coordinated

json.work_history user.work_history, partial: 'signups/signup', as: :signup
json.work_intents user.work_intents, partial: 'signups/signup', as: :signup

json.roles user.roles.collect {|r| r.name}

json.suggestions user.suggestions
