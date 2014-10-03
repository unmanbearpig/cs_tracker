
# TODO: ArrayDiff?
## Creazy idea: blame?

class HashDiff
  attr_reader :hash1, :hash2

  def initialize hash1, hash2, options = {}
    @hash1, @hash2 = hash1, hash2

    @options = (options ? options : {})
  end

  def ignore_keys
    @options.key?(:ignore_keys) ? @options[:ignore_keys] : [];
  end

  def keys1
    @keys1 ||= Set.new(hash1.keys) - ignore_keys
  end

  def keys2
    @keys2 ||= Set.new(hash2.keys) - ignore_keys
  end

  def modified_keys
    Set.new((keys1 & keys2).select { |key| hash1[key] != hash2[key] })
  end

  def changed?
    # make it faster?
    diff.any?
  end

  def diff
    result = (modified_keys + added_keys)
      .reduce({}) { |new_hash, mkey| new_hash[mkey] = diff_if_hashes(hash1[mkey], hash2[mkey]); new_hash }

    result.merge! __deleted__: removed_keys.to_a if removed_keys.any?
    result.merge! __added__: added_keys.to_a if added_keys.any?
    result
  end

  def kind_of_hash? object
    %w(keys [] merge).map(&:to_sym)
      .map { |method| object.respond_to?(method) }
      .select { |result| result == false }
      .empty?
  end

  def diff_if_hashes old_value, new_value
    if kind_of_hash?(old_value) && kind_of_hash?(new_value)
      HashDiff.new(old_value, new_value, @options).diff
    else
      new_value
    end
  end

  def removed_keys
    keys1 - keys2
  end

  def added_keys
    keys2 - keys1
  end

  def to_h
    diff
  end

  def self.diff(hash1, hash2, options = {})
    HashDiff.new(hash1, hash2, options).diff
  end

  def self.patch(hash, diff)
    raise "not_ implemented. Also, test! It's easy!"
  end

  def self.test sr1, sr2, options = {}
    h1 = sr1.search_items.reduce({}) { |c, i| c[i.profile_id] = i.to_h; c }
    h2 = sr2.search_items.reduce({}) { |c, i| c[i.profile_id] = i.to_h; c }

    return self.new(h1, h2, options)
  end
end
