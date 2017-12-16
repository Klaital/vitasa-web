module CachingHelper
  def schedule_cache_prefix
    "sites_data_"
  end

  def expire_schedule_cache
    $redis.del($redis.keys(schedule_cache_prefix))
  end
end

