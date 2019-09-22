json.cache! ['v1', user] do
  json.extract! user, :id, :name, :email, :phone,
              :organization_id, :certification,
              :subscribe_mobile, :hsa_certification, :military_certification,
              :international_certification

  json.work_history user.work_logs,
                    partial: 'work_logs/work_log',
                    as: :work_log

  json.roles user.roles.collect(&:name)

  json.suggestions user.suggestions

  json.preferred_sites user.preferred_sites.collect(&:slug)

  json.sites_coordinated user.sites_coordinated,
                         partial: 'sites/sc_details',
                         as: :site
end