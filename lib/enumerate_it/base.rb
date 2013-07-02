# encoding: utf-8
module EnumerateIt
  class Base
    @@registered_enumerations = {}

    class << self
      attr_reader :sort_mode
    end

    def self.associate_values(*args)
      values_hash = args.first.is_a?(Hash) ? args.first : args.inject({}) { |h, v| h[v] = v.to_s; h }

      register_enumeration normalize_enumeration(values_hash)
      values_hash.each_pair { |value_name, attributes| define_enumeration_constant value_name, attributes[0] }
    end

    def self.sort_by(sort_mode)
      @sort_mode = sort_mode
    end

    def self.list
      enumeration.values.map { |value| value[0] }.sort
    end

    def self.enumeration
      @@registered_enumerations[self]
    end

    def self.to_a
      sorted_map.map { |k, v| [translate(v[1]), v[0]] }
    end

    def self.length
      list.length
    end

    def self.each_translation
      each_value { |value| yield t(value) }
    end

    def self.each_value
      list.each { |value| yield value }
    end

    def self.to_json
      sorted_map.map { |k, v| { :value => v[0], :label => translate(v[1]) } }.to_json
    end

    def self.t(value)
      target = to_a.detect { |item| item[1] == value }
      target ? target[0] : value
    end

    def self.values_for(values)
      values.map { |v| self.const_get(v.to_sym) }
    end

    def self.value_for(value)
      self.const_get(value.to_sym)
    end

    def self.keys
      enumeration.keys
    end

    def self.key_for(value)
      enumeration.map {|e| e[0] if e[1][0] == value }.compact.first
    end

    def self.to_range
      (list.min..list.max)
    end

    private

    def self.sorted_map
      enumeration.sort_by { |k, v| sort_lambda.call(k, v) }
    end

    def self.sort_lambda
      {
        :value       => lambda { |k, v| v[0] },
        :name        => lambda { |k, v| k },
        :translation => lambda { |k, v| translate(v[1]) },
        :none        => lambda { |k, v| nil }
      }[sort_mode || :translation]
    end

    def self.translate(value)
      return value unless value.is_a? Symbol

      default = value.to_s.gsub(/_/, ' ').split.map(&:capitalize).join(' ')
      I18n.t("enumerations.#{self.name.underscore}.#{value.to_s.underscore}", :default => default)
    end

    def self.normalize_enumeration(values_hash)
      values_hash.each_pair do |key, value|
        unless value.is_a? Array
          values_hash[key] = [value, key]
        end
      end
    end

    def self.register_enumeration(values_hash)
      @@registered_enumerations[self] = values_hash
    end

    def self.define_enumeration_constant(name, value)
      const_set name.to_s.upcase, value
    end
  end
end
