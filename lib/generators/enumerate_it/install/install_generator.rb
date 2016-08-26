module EnumerateIt
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializer_file
        template 'enumerate_it_initializer.rb', File.join('config/initializers/', 'enumerate_it.rb')
      end
    end
  end
end
