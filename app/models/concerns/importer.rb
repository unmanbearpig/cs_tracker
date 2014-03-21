module Importer
  # Expects import_hash class method

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    # expects either hash or object that has to_h method or an array of them
    def import data, *args
      if data.kind_of? Array
        import_multiple_items data, *args
      else
        import_single_item data, *args
      end
    end

    def import_multiple_items array, *args
      array.map { |item| import_single_item item, *args }
    end

    def import_single_item data, *args
      if data.kind_of? Hash
        import_hash data, *args
      elsif data.respond_to? :to_h
        import_hash data.to_h, *args
      else
        fail 'Argument is not a hash and doesn\'t respond to to_h'
      end
    end
  end
end
