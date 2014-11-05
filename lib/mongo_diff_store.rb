require 'hash_diff'

class MongoDiffStore
  include Enumerable
  META_KEYS = ['_id']

  attr_reader :mongo_address, :db_name, :safe

  attr_accessor :collection_name

  def initialize db_name, collection, mongo_address: '127.0.0.1:27017', safe: true
    @db_name, @collection_name = db_name, collection
    @mongo_address, @safe = mongo_address, safe
  end

  def session
    unless @session
      @session = Moped::Session.new([mongo_address])
      @session.use db_name
    end
    @session
  end

  def collection
    session.with(safe: safe)[collection_name]
  end

  def query *args
    collection.find(*args)
  end

  def push! data
    push_multiple! [data]
  end

  def push_multiple! data_enumerable
    current = latest || {}

    data_enumerable.each do |data|
      data = data.stringify_keys

      push_single! current, data

      current = data
    end
  end

  def push_single! current, new_object
    diff = HashDiff.diff(current, new_object, ignore_keys: META_KEYS)
    insert 'diff' => diff, 'id' => new_object['id'], 'created_at' => new_object['created_at']
  end

  def each &block
    return self.to_enum { query.count } unless block_given?
    result = {}

    oldest_first.each do |diff|
      result = HashDiff.patch! result, diff
      yield result
    end
  end

  def size
    query.count
  end

  def last
    result = nil
    each { |item| result = item }

    result
  end

  def latest
    last
  end

  def latest_diff
    newest_first.one
  end

  protected

  def newest_first
    query.sort(created_at: -1)
      .lazy.map { |obj| deserialize obj }
  end

  def oldest_first
    query.sort(created_at: 1)
      .lazy.map { |obj| deserialize obj }
  end

  def deserialize obj
    return nil unless obj
    return obj['diff'] if obj.has_key? 'diff'
  end

  def serialize obj
    {'diff' => obj}
  end

  def insert data
    collection.insert data
  end
end
