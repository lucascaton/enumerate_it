require 'active_support/core_ext/class/attribute'
require 'active_support/inflector'
require 'enumerate_it/base'
require 'enumerate_it/class_methods'

module EnumerateIt
  def self.extended(receiver)
    receiver.class_attribute :enumerations, instance_writer: false, instance_reader: false
    receiver.enumerations = {}

    receiver.extend ClassMethods
  end
end

ActiveSupport.on_load(:active_record) { ActiveRecord::Base.extend EnumerateIt }
