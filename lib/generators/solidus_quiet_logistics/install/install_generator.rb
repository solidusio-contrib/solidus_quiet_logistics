# frozen_string_literal: true

module SolidusQuietLogistics
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      class_option :auto_run_migrations, type: :boolean, default: false

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=solidus_quiet_logistics'
      end

      def copy_executables
        template('resource/ql-poller', 'bin/ql-poller')
        run 'chmod +x bin/ql-poller'
      end

      def copy_initializer
        template('resource/initializer.rb', 'config/initializers/quiet_logistics.rb')
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end
    end
  end
end
