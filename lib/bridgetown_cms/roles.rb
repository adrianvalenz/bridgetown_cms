# frozen_string_literal: true

require_relative 'database'

module BridgetownCms
  module Roles
    class << self
      # Get role for an account
      def get_role(account_id)
        role_record = Database.connection[:cms_roles].where(account_id: account_id).first
        role_record ? role_record[:role] : nil
      end

      # Check if account is admin
      def admin?(account_id)
        get_role(account_id) == 'admin'
      end

      # Check if account can edit a specific post
      def can_edit_post?(account_id, post)
        return true if admin?(account_id)

        # Get account email
        account = Database.connection[:accounts].where(id: account_id).first
        return false unless account

        # Check if post author matches account email
        post[:author_email] == account[:email]
      end

      # Get display name for account
      def get_display_name(account_id)
        role_record = Database.connection[:cms_roles].where(account_id: account_id).first
        role_record ? role_record[:display_name] : nil
      end

      # Create role for account
      def create_role(account_id, role, display_name = nil)
        Database.connection[:cms_roles].insert(
          account_id: account_id,
          role: role,
          display_name: display_name,
          created_at: Time.now,
          updated_at: Time.now
        )
      end

      # Update role for account
      def update_role(account_id, role, display_name = nil)
        Database.connection[:cms_roles].where(account_id: account_id).update(
          role: role,
          display_name: display_name,
          updated_at: Time.now
        )
      end

      # Delete role for account
      def delete_role(account_id)
        Database.connection[:cms_roles].where(account_id: account_id).delete
      end

      # Get account email
      def get_account_email(account_id)
        account = Database.connection[:accounts].where(id: account_id).first
        account ? account[:email] : nil
      end
    end
  end
end
