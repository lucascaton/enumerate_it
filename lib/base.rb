module EnumerateIt
  class Base
    @@registered_enumerations = {}

    def self.associate_values(values_hash)
      register_enumeration normalize_enumeration(values_hash)
      values_hash.each_pair { |value_name, attributes| define_enumeration_constant value_name, attributes[0] }
      define_enumeration_list values_hash
    end 

    private
    def self.normalize_enumeration(values_hash)
      values_hash.each_pair do |key, value| 
        unless value.is_a? Array
          values_hash[key] = [value, key]
        end
      end
      values_hash
    end

    def self.register_enumeration(values_hash)
      @@registered_enumerations[self] = values_hash
    end

    def self.define_enumeration_constant(name, value)
      const_set name.to_s.upcase, value
    end

    def self.define_enumeration_list(values_hash)
      def self.list 
        @@registered_enumerations[self].values.map { |value| translate(value[0]) }.sort
      end

      def self.enumeration
        @@registered_enumerations[self]
      end
      
      def self.to_a
        @@registered_enumerations[self].values.map {|value| [translate(value[1]), value[0]] }.sort_by { |value| value[0] }
      end

      def self.values_for(values)
        values.map { |v| self.const_get(v.to_sym) }
      end
      
      def self.translate(value)
        return value unless value.is_a? Symbol
      
        default = value.to_s.to_s.gsub(/_/, ' ').split.map(&:capitalize).join(' ')
        I18n.t("enumerations.#{self.name.underscore}.#{value.to_s.underscore}", :default => default)
      end
    end
  end
end
