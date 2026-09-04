# frozen_string_literal: true

require 'sequel'
require 'fileutils'

module BridgetownCms
  module Database
    class << self
      attr_accessor :db

      # Initialize database connection
      def connection
        @db ||= initialize_connection
      end

      # Check if database file exists and has users
      def has_users?
        return false unless File.exist?(database_path)

        connection[:accounts].count > 0
      rescue Sequel::DatabaseError
        false
      end

      # Get database path from configuration or use default
      def database_path
        if defined?(Bridgetown.configuration) && Bridgetown.configuration.bridgetown_cms&.database_path
          File.join(Bridgetown.configuration.root_dir, Bridgetown.configuration.bridgetown_cms.database_path)
        else
          File.join(Bridgetown.configuration.root_dir, "config", "bridgetown_cms.db")
        end
      end

      private

      def initialize_connection
        # Ensure config directory exists
        FileUtils.mkdir_p(File.dirname(database_path))

        # Connect to SQLite database
        db = Sequel.connect("sqlite://#{database_path}")

        # Run migrations if needed
        run_migrations(db)

        db
      end

      def run_migrations(db)
        # Only run migrations if tables don't exist
        return if db.table_exists?(:accounts)

        Bridgetown.logger.info "🔧", "Running Bridgetown CMS database migrations..."

        db.create_table(:accounts) do
          primary_key :id
          String :email, null: false
          String :password_hash, null: false
          Time :created_at
          Time :updated_at

          index :email, unique: true
        end

        # Rodauth password reset keys table
        db.create_table(:account_password_reset_keys) do
          foreign_key :id, :accounts, primary_key: true, type: :integer
          String :key, null: false
          Time :deadline, null: false
          Time :email_last_sent, null: false, default: Sequel::CURRENT_TIMESTAMP
        end

        # Rodauth remember keys table (for "remember me" functionality)
        db.create_table(:account_remember_keys) do
          foreign_key :id, :accounts, primary_key: true, type: :integer
          String :key, null: false
          Time :deadline, null: false
        end

        # Custom CMS roles table
        db.create_table(:cms_roles) do
          primary_key :id
          foreign_key :account_id, :accounts, null: false, type: :integer
          String :role, null: false, default: 'author' # 'admin' or 'author'
          String :display_name
          Time :created_at
          Time :updated_at

          index :account_id, unique: true
        end

        Bridgetown.logger.info "✅", "Bridgetown CMS database migrations complete!"
      end
    end
  end
end
