# encoding: utf-8

# EnumerateIt - Ruby Enumerations
#
# Author: Cássio Marques - cassiommc at gmail
#
# = Description
#
# Ok, I know there are a lot of different solutions to this problem. But none of them solved my problem,
# so here's EnumerateIt. I needed to build a Rails application around a legacy database and this database was
# filled with those small, unchangeable tables used to create foreign key constraints everywhere.
#
# == For example:
#
#      Table "public.relationshipstatus"
#   Column     |     Type      | Modifiers
# -------------+---------------+-----------
#  code        | character(1)  | not null
#  description | character(11) |
# Indexes:
#     "relationshipstatus_pkey" PRIMARY KEY, btree (code)
#
#  select * from relationshipstatus;
#  code   |  description
# --------+--------------
#  1      | Single
#  2      | Married
#  3      | Widow
#  4      | Divorced
#
# And then I had things like a people table with a 'relationship_status' column with a foreign key
# pointing to the relationshipstatus table.
#
# While this is a good thing from the database normalization perspective, managing this values in
# my tests was very hard. More than this, referencing them in my code using magic numbers was terrible
# and meaningless: What's does it mean when we say that someone or something is '2'?
#
# Enter EnumerateIt.
#
# = Creating enumerations
#
# Enumerations are created as models, but you can put then anywhere in your application. In Rails
# applications, I put them inside models/.
#
# class RelationshipStatus < EnumerateIt::Base
#   associate_values(
#     :single   => [1, 'Single'],
#     :married  => [2, 'Married'],
#     :widow    => [3, 'Widow'],
#     :divorced => [4, 'Divorced'],
#   )
# end
#
# This will create some nice stuff:
#
# - Each enumeration's value will turn into a constant:
#
# RelationshipsStatus::SINGLE # returns 1
# RelationshipStatus::MARRIED # returns 2 and so on...
#
# - You can retrieve a list with all the enumeration codes:
#
# RelationshipStatus.list # [1,2,3,4]
#
# You can get an array of options, ready to use with the 'select', 'select_tag', etc family of Rails helpers.
#
# RelationshipStatus.to_a # [["Divorced", 4],["Married", 2],["Single", 1],["Widow", 3]]
#
# You can retrive a list with values for a group of enumeration constants
#
# RelationshipStatus.valus_for %w(MARRIED SINGLE) # [2, 1]
#
# - You can manipulate the has used to create the enumeration:
#
# RelationshipStatus.enumeration # returns the exact hash used to define the enumeration
#
# = Using enumerations
#
# The cool part is that you can use these enumerations with any class, be it an ActiveRecord instance
# or not.
#
# class Person
#   include EnumerateIt
#   attr_accessor :relationship_status
#
#   has_enumeration_for :relationship_status, :with => RelationshipStatus
# end
#
# The :with option is not required. If you ommit it, EnumerateIt will try to load an
# enumeration class based on the camelized attribute name.
#
# This will create:
#
# - A humanized description for the values of the enumerated attribute:
#
# p = Person.new
# p.relationship_status = RelationshipStatus::DIVORCED
# p.relationship_status_humanize # => 'Divorced'
#
# - If you don't supply a humanized string to represent an option, EnumerateIt will use a 'humanized'
# version of the hash's key to humanize the attribute's value
#
#  class RelationshipStatus < EnumerateIt::Base
#    associate_values(
#      :married => 1,
#      :single => 2
#    )
#  end
#
#  p = Person.new
#  p.relationship_status = RelationshipStatus::MARRIED
#  p.relationship_status_humanize # => 'Married'
#
# - If you pass the :create_helpers option as 'true', it will create a helper method for each enumeration
#  option (this option defaults to false):
#
#  class Person < ActiveRecord::Base
#    has_enumeration_for :relationship_status, :with => RelationshipStatus, :create_helpers => true
#  end
#
#  p = Person.new
#  p.relationship_status = RelationshipStatus::MARRIED
#  p.married? #=> true
#  p.divorced? #=> false
#
# - If your class can manage validations and responds to :validates_inclusion_of, it will create this
# validation:
#
# class Person < ActiveRecord::Base
#   has_enumeration_for :relationship_status, :with => RelationshipStatus
# end
#
# p = Person.new :relationship_status => 6 # => there is no '6' value in the enumeration
# p.valid? # => false
# p.errors[:relationship_status] # => "is not included in the list"
#
# - Also, if your class responds to :validates_presence_of, you can pass an :required option and this validation
# will be added to your attribute:
#
# class Person < ActiveRecord::Base
#   has_enumeration_for :relationship_status, :required => true # => defaults to false
# end
#
# Remember that in Rails 3 you can add validations to any kind of class and not only to those derived from
# ActiveRecord::Base.
#
# = Using with Rails/ActiveRecord
#
# * Create an initializer with the following code:
#
# ActiveRecord::Base.send :include, EnumerateIt
#
# * Add the 'enumerate_it' gem as a dependency in your environment.rb (Rails 2.3.x) or Gemfile (if you're using Bundler)
#
# = Why did you reinvent the wheel?
#
# There are other similar solutions to the problem out there, but I could not find one that
# worked both with strings and integers as the enumerations' codes. I had both situations in
# my legacy database.
#
# = Why defining enumerations outside the class that used it?
#
# - I think it's cleaner.
# - You can add behaviour to the enumeration class.
# - You can reuse the enumeration inside other classes.
#
module EnumerateIt
  class Base
    @@registered_enumerations = {}

    def self.associate_values(values_hash)
      register_enumeration normalize_enumeration(values_hash)
      values_hash.each_pair { |value_name, attributes| define_enumeration_constant value_name, attributes[0] }
    end

    def self.list
      enumeration.values.map { |value| value[0] }.sort
    end

    def self.enumeration
      @@registered_enumerations[self]
    end

    def self.to_a
      enumeration.values.map {|value| [translate(value[1]), value[0]] }.sort_by { |value| value[0] }
    end

    def self.values_for(values)
      values.map { |v| self.const_get(v.to_sym) }
    end

    def self.translate(value)
      return value unless value.is_a? Symbol

      default = value.to_s.to_s.gsub(/_/, ' ').split.map(&:capitalize).join(' ')
      I18n.t("enumerations.#{self.name.underscore}.#{value.to_s.underscore}", :default => default)
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

  end

  module ClassMethods
    def has_enumeration_for(attribute, options = {})
      define_enumeration_class attribute, options
      set_validations attribute, options
      create_enumeration_humanize_method options[:with], attribute
      if options[:create_helpers]
        create_helper_methods options[:with], attribute
      end
    end

    private
    def create_enumeration_humanize_method(klass, attribute_name)
      class_eval do
        define_method "#{attribute_name}_humanize" do
          values = klass.enumeration.values.detect { |v| v[0] == self.send(attribute_name) }

          values ? klass.translate(values[1]) : nil
        end
      end
    end

    def create_helper_methods(klass, attribute_name)
      class_eval do
        klass.enumeration.keys.each do |option|
          define_method "#{option}?" do
            self.send(attribute_name) == klass.enumeration[option].first
          end
        end
      end
    end

    def define_enumeration_class(attribute, options)
      if options[:with].blank?
        options[:with] = attribute.to_s.camelize.constantize
      end
    end

    def set_validations(attribute, options)
      validates_inclusion_of(attribute, :in => options[:with].list, :allow_blank => true) if self.respond_to?(:validates_inclusion_of)
      validates_presence_of(attribute) if options[:required] and self.respond_to?(:validates_presence_of)
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end


