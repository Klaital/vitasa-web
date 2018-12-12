json.extract! user, :id, :name, :email, :phone, :certification, :subscribe_mobile

json.work_history user.work_logs, partial: 'work_logs/work_log', as: :work_log

json.roles user.roles.collect {|r| r.name}

json.suggestions user.suggestions

json.preferred_sites user.preferred_sites.collect {|s| s.slug}

json.sites_coordinated user.sites_coordinated, partial: 'sites/sc_details', as: :site