# encoding: utf-8
module EnumerateIt
  module ClassMethods
    def has_enumeration_for(attribute, options = {})
      self.enumerations = self.enumerations.dup

      define_enumeration_class attribute, options
      set_validations attribute, options
      create_enumeration_humanize_method options[:with], attribute
      store_enumeration options[:with], attribute
      if options[:create_helpers]
        create_helper_methods options[:with], attribute, options[:create_helpers]
        create_mutator_methods options[:with], attribute, options[:create_helpers]
      end

      if options[:create_scopes]
        create_scopes options[:with], attribute
      end
    end

    private
    def store_enumeration(klass, attribute)
      enumerations[attribute] = klass
    end

    def create_enumeration_humanize_method(klass, attribute_name)
      class_eval do
        define_method "#{attribute_name}_humanize" do
          values = klass.enumeration.values.detect { |v| v[0] == self.send(attribute_name) }

          values ? klass.translate(values[1]) : nil
        end
      end
    end

    def create_helper_methods(klass, attribute_name, helpers)
      prefix_name = "#{attribute_name}_" if helpers.is_a?(Hash) && helpers[:prefix]

      class_eval do
        klass.enumeration.keys.each do |option|
          define_method "#{prefix_name}#{option}?" do
            self.send(attribute_name) == klass.enumeration[option].first
          end
        end
      end
    end

    def create_scopes(klass, attribute_name)
      klass.enumeration.keys.each do |option|
        if respond_to? :scope
          scope option, lambda { where(attribute_name => klass.enumeration[option].first)}
        end
      end
    end

    def create_mutator_methods(klass, attribute_name, helpers)
      prefix_name = "#{attribute_name}_" if helpers.is_a?(Hash) && helpers[:prefix]

      class_eval do
        klass.enumeration.each_pair do |key, values|
          define_method "#{prefix_name}#{key}!" do
            self.send "#{attribute_name}=", values.first
          end
        end
      end
    end

    def define_enumeration_class(attribute, options)
      if options[:with].nil?
        options[:with] = attribute.to_s.camelize.constantize
      end
    end

    def set_validations(attribute, options)
      validates_inclusion_of(attribute, :in => options[:with].list, :allow_blank => true) if self.respond_to?(:validates_inclusion_of)

      if options[:required] && respond_to?(:validates_presence_of)
        opts = options[:required].is_a?(Hash) ? options[:required] : {}
        validates_presence_of(attribute, opts)
      end
    end
  end
end
