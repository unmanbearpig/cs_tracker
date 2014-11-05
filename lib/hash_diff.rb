module DiffableHash
  def diff(other_hash)
    HashDiff.diff(self, other_hash)
  end
end

# TODO: ArrayDiff?
## Creazy idea: blame?

class HashDiff
  attr_reader :hash1, :hash2

  ADDED = '__added__'
  DELETED = '__deleted__'

  def initialize hash1, hash2, options = {}
    @hash1, @hash2 = hash1.freeze, hash2.freeze

    @options = (options ? options : {}).freeze
  end

  def ignore_keys
    @ignore_key ||= (@options.key?(:ignore_keys) ? @options[:ignore_keys] : []).freeze
  end

  def keys1
    @keys1 ||= (Set.new(hash1.keys) - ignore_keys).freeze
  end

  def keys2
    @keys2 ||= (Set.new(hash2.keys) - ignore_keys).freeze
  end

  def modified_keys
    @modified_keys ||= Set.new((keys1 & keys2).select { |key| hash1[key] != hash2[key] }).freeze
  end

  def changed?
    # make it faster?
    diff.any?
  end

  def diff
    result = {}
    (modified_keys + added_keys).each do |key|
      result[key] = self.class.diff_if_hashes(hash1[key], hash2[key])
    end

    result[DELETED] = removed_keys.to_a if removed_keys.any?
    result[ADDED] = added_keys.to_a if added_keys.any?
    result
  end

  def self.kind_of_hash? object
    object.respond_to?(:keys) && object.respond_to?(:[]) && object.respond_to?(:merge)
  end

  def self.diff_if_hashes old_value, new_value
    if kind_of_hash?(old_value) && kind_of_hash?(new_value)
      HashDiff.diff(old_value, new_value, @options)
    else
      new_value
    end
  end

  def removed_keys
    @removed_keys ||= (keys1 - keys2).freeze
  end

  def added_keys
    @added_keys ||= (keys2 - keys1).freeze
  end

  def to_h
    diff
  end

  def self.diff(hash1, hash2, options = {})
    HashDiff.new(hash1, hash2, options).diff
  end

  def self.is_kind_of_hashy object
    object.respond_to?(:[]) && object.respond_to?(:keys) && object.respond_to?(:values)
  end

  def self.patch!(hash, diff)
    return diff unless is_kind_of_hashy(hash) && is_kind_of_hashy(diff)

    validate_patch hash, diff

    result = hash.dup

    diff.keys.each do |k|
      result[k] = patch!(result[k], diff[k]) unless k == ADDED || k == DELETED
    end

    if diff.has_key? DELETED
      diff[DELETED].each do |key|
        result.delete key
      end
    end

    result
  end

  def self.validate_patch orig, patch
    if patch.has_key? DELETED
      patch[DELETED].each do |key|
        raise "Deleted key \"#{key}\" doesn't exist in original hash" unless orig.has_key? key
        raise "Deleted key \"#{key}\" exist in HashPatch" if patch.has_key? key
      end
    end

    if patch.has_key? ADDED
      patch[ADDED].each do |key|
        raise "Added key \"#{key}\" exists in original hash" if orig.has_key? key
        raise "Key from __added__ array is missing in patch" unless patch.has_key? key
      end
    end
  end
end

class HashDiffConveyor
  attr_accessor :options

  def initialize options = {}
    @options = options
  end

  attr_writer :last

  def last
    @last || {}
  end

  def diff hash
    diff = HashDiff.diff(last, hash, options)
    self.last = hash
    diff
  end

end


class LazyIterator
  include Enumerable

  def initialize next_item_lambda
    @next_item_lambda = next_item_lambda
  end

  def each &block
    while item = @next_item_lambda.call
      yield item unless item == nil
    end
  end
end


class LazyBufferedIterator < LazyIterator
  def initialize batch_size, fetcher_lambda
    @batch_size = batch_size
    @fetcher_lambda = fetcher_lambda
  end

  def get_batch page_num
    @fetcher_lambda.call(@batch_size, page_num)
  end

  def each &block
    page_num = 0
    while batch = get_batch(page_num)
      return unless batch.respond_to?(:each) && batch.respond_to?(:any?) && batch.any?

      batch.each &block

      page_num += 1
    end
  end
end
