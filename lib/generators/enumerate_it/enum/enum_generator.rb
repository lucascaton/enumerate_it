module EnumerateIt
  module Generators
    class EnumGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      argument :attributes, type: 'array', default: []

      class_option :singular, type: 'string', desc: 'Singular name for i18n'

      class_option :lang, type: 'string', desc: 'Language to use in i18n', default: 'en'

      desc 'Creates a locale file on config/locales'
      def create_locale
        template 'locale.yml', File.join('config/locales', "#{singular_name}.yml")
      end

      desc 'Creates an initializer file that extends ActiveRecord::Base with Enumerate_it'
      def create_enumerate_it
        template 'enumerate_it.rb', File.join('app/enumerations', "#{singular_name}.rb")
      end

      protected

      def default_lang
        options[:lang]
      end

      def singular
        singular_name
      end

      def locale_fields
        attributes.map(&:name)
      end

      def fields
        if attributes.first.type == :string
          attributes.map(&:name)
        else
          attributes.map { |attribute| [attribute.name, attribute.type] }
        end
      end
    end
  end
end
