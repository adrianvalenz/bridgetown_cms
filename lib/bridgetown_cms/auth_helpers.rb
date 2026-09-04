# frozen_string_literal: true

require_relative 'database'
require_relative 'roles'

module BridgetownCms
  module AuthHelpers
    # Get current logged-in user
    def current_user
      return nil unless rodauth.logged_in?

      @current_user ||= Database.connection[:accounts].where(id: rodauth.account_id).first
    end

    # Get current user's email
    def current_user_email
      current_user ? current_user[:email] : nil
    end

    # Get current user's role
    def current_user_role
      return nil unless current_user

      Roles.get_role(current_user[:id])
    end

    # Check if current user is admin
    def current_user_admin?
      return false unless current_user

      Roles.admin?(current_user[:id])
    end

    # Require admin role (call in routes)
    def require_admin!
      unless current_user_admin?
        response.status = 403
        return render_error_page("Forbidden", "Admin access required")
      end
    end

    # Check if current user can edit a post
    def can_edit_post?(post)
      return false unless current_user

      Roles.can_edit_post?(current_user[:id], post)
    end

    # Get flash messages
    def flash_message(type)
      message = session.delete(:"#{type}_flash")
      return nil unless message

      case type
      when :success
        render_flash_message(message, 'green')
      when :error
        render_flash_message(message, 'red')
      when :warning
        render_flash_message(message, 'yellow')
      else
        render_flash_message(message, 'blue')
      end
    end

    # Render flash message HTML
    def render_flash_message(message, color)
      <<~HTML
        <div class="mb-4 p-4 rounded-lg bg-#{color}-50 border border-#{color}-200">
          <p class="text-#{color}-800">#{message}</p>
        </div>
      HTML
    end

    # Render error page
    def render_error_page(title, message)
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>#{title} - Bridgetown CMS</title>
          <script src="https://cdn.tailwindcss.com"></script>
        </head>
        <body class="bg-gray-100">
          <div class="min-h-screen flex items-center justify-center">
            <div class="bg-white p-8 rounded-lg shadow-md max-w-md">
              <h1 class="text-2xl font-bold text-red-600 mb-4">#{title}</h1>
              <p class="text-gray-700">#{message}</p>
              <div class="mt-6">
                <a href="/admin" class="text-blue-600 hover:text-blue-800">← Back to Dashboard</a>
              </div>
            </div>
          </div>
        </body>
        </html>
      HTML
    end
  end
end
