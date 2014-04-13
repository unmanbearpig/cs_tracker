module ModelCache
  protected

  def cache_store
    @cache_store ||= Redis::Namespace.new "#{self.class.to_s}:cache"
  end

  def cache id, value
    cache_store.set id, JSON.dump(value)
  end

  def fetch_cache id
    JSON.load cache_store.get(id)
  end

  def del_cache id
    cache_store.del id
  end

  def cached_query id, klass, &block
    cached_value = fetch_cache(id)
    if cached_value
      result = JSON.load(cached_value).map { |item| klass.find item }
      result
    else
      result = yield
      cache id, JSON.dump(result.map { |record| record.id })
      result
    end
  end
end
