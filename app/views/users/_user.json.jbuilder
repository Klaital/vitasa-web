json.extract! user, :id, :name, :email, :phone, :certification

json.work_history Signup.where('user_id == :user_id AND date < :date', {:user_id => user.id, :date => Date.today}), 
                    partial: 'signups/signup', 
                    as: :signup

json.work_intents Signup.where('user_id == :user_id AND date >= :date', {:user_id => user.id, :date => Date.today}), 
                    partial: 'signups/signup', 
                    as: :signup

json.roles user.roles.collect {|r| r.name}

json.suggestions Suggestion.where(user_id: user.id),
                    partial: 'suggestions/suggestion',
                    as: :suggestion
