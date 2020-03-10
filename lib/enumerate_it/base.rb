require 'forwardable'

module EnumerateIt
  class Base
    class << self
      extend Forwardable

      attr_reader :sort_mode

      def_delegators :enumeration, :keys, :each_key

      def associate_values(*args)
        values = values_hash(args)

        register_enumeration(normalize_enumeration(values))

        values.each_pair do |value_name, attributes|
          define_enumeration_constant value_name, attributes[0]
        end
      end

      def sort_by(sort_mode)
        @sort_mode = sort_mode
      end

      def list
        sorted_map.map { |_k, v| v.first }
      end

      def to_h
        sorted_map.transform_values(&:first)
      end

      def enumeration
        @registered_enumerations[self]
      end

      def to_a
        sorted_map.map { |_k, v| [translate(v[1]), v[0]] }
      end

      def length
        list.length
      end

      def each_translation
        each_value { |value| yield t(value) }
      end

      def translations
        list.map { |value| t(value) }
      end

      def each_value
        list.each { |value| yield value }
      end

      def to_json(options = nil)
        sorted_map.map { |_k, v| { value: v[0], label: translate(v[1]) } }.to_json(options)
      end

      def t(value)
        target = to_a.detect { |item| item[1] == value }
        target ? target[0] : value
      end

      def values_for(values)
        values.map { |v| value_for v.to_sym }
      end

      def value_for(value)
        const_get(value.to_sym)
      rescue NameError
        nil
      end

      def value_from_key(key)
        return if key.nil?

        (enumeration[key.to_sym] || []).first
      end

      def key_for(value)
        enumeration.map { |e| e[0] if e[1][0] == value }.compact.first
      end

      def to_range
        (list.min..list.max)
      end

      def translate(value)
        return value unless value.is_a? Symbol

        default = value.to_s.tr('_', ' ').split.map(&:capitalize).join(' ')
        I18n.t("enumerations.#{name.underscore}.#{value.to_s.underscore}", default: default)
      end

      private

      def sorted_map
        return enumeration if sort_mode.nil? || sort_mode == :none

        enumeration.sort_by { |k, v| sort_lambda.call(k, v) }
      end

      def sort_lambda
        {
          value:       ->(_k, v) { v[0] },
          name:        ->(k, _v) { k },
          translation: ->(_k, v) { translate(v[1]) }
        }[sort_mode]
      end

      def normalize_enumeration(values_hash)
        values_hash.each_pair do |key, value|
          values_hash[key] = [value, key] unless value.is_a? Array
        end
      end

      def register_enumeration(values_hash)
        @registered_enumerations ||= {}
        @registered_enumerations[self] = values_hash
      end

      def define_enumeration_constant(name, value)
        const_set name.to_s.tr('-', '_').gsub(/\p{blank}/, '_').upcase, value
      end

      def values_hash(args)
        return args.first if args.first.is_a?(Hash)

        args.each_with_object({}) do |value, hash|
          hash[value] = value.to_s
        end
      end
    end
  end
end
