module CachingHelper
  def schedule_cache_prefix
    "sites_data_"
  end

  def expire_schedule_cache
    keys = $redis.keys("#{schedule_cache_prefix}*")
    $redis.del(keys) unless keys.nil? || keys.empty?
  end
end

