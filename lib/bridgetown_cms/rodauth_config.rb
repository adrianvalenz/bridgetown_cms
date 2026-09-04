# frozen_string_literal: true

require 'rodauth'
require 'securerandom'
require_relative 'database'

module BridgetownCms
  class RodauthConfig
    def self.configure(roda_class)
      # Enable sessions if not already enabled
      unless roda_class.opts[:sessions]
        roda_class.plugin :sessions, secret: ENV.fetch("SESSION_SECRET", SecureRandom.hex(64))
      end

      roda_class.plugin :rodauth do
        # Enable features
        enable :login, :logout, :reset_password, :change_password, :remember

        # Database configuration
        db { BridgetownCms::Database.connection }
        accounts_table :accounts

        # Session configuration
        session_key 'bridgetown_cms_session'
        remember_cookie_key 'bridgetown_cms_remember'

        # Path prefix for all Rodauth routes
        prefix '/admin'

        # Redirect paths
        login_redirect '/admin'
        logout_redirect '/admin/login'
        require_login_redirect '/admin/login'
        reset_password_redirect '/admin/login'

        # Account-related configuration
        account_password_hash_column :password_hash

        # Login/logout configuration
        login_route 'login'
        logout_route 'logout'
        reset_password_route 'reset-password'
        reset_password_request_route 'reset-password-request'
        change_password_route 'change-password'

        # Email configuration (will be customizable)
        email_from { 'noreply@example.com' }
        reset_password_email_subject 'Reset Your Password - Bridgetown CMS'

        # Custom hooks
        after_login do
          # Set flash message
          session[:success_flash] = "Welcome back, #{account[:email]}!"
        end

        after_logout do
          session[:success_flash] = "You have been logged out."
        end

        # Custom login page template
        login_view do
          <<~HTML
            <!DOCTYPE html>
            <html>
            <head>
              <title>Login - Bridgetown CMS</title>
              <script src="https://cdn.tailwindcss.com"></script>
            </head>
            <body class="bg-gray-100">
              <div class="min-h-screen flex items-center justify-center">
                <div class="bg-white p-8 rounded-lg shadow-md w-96">
                  <h1 class="text-2xl font-bold mb-6">Bridgetown CMS</h1>

                  <form method="post" action="#{login_path}" class="space-y-4">
                    #{csrf_tag}

                    <div>
                      <label for="login" class="block text-sm font-medium text-gray-700 mb-2">
                        Email
                      </label>
                      <input type="email" id="login" name="login" required autofocus
                             value="#{param('login')}"
                             class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                             placeholder="Enter your email" />
                    </div>

                    <div>
                      <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                        Password
                      </label>
                      <input type="password" id="password" name="password" required
                             class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                             placeholder="Enter your password" />
                    </div>

                    <div class="flex items-center">
                      <input type="checkbox" id="remember" name="remember" value="t"
                             class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" />
                      <label for="remember" class="ml-2 block text-sm text-gray-700">
                        Remember me
                      </label>
                    </div>

                    <button type="submit"
                            class="w-full px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                      Sign In
                    </button>
                  </form>

                  <div class="mt-4 text-sm text-center">
                    <a href="#{reset_password_request_path}" class="text-blue-600 hover:text-blue-800">
                      Forgot your password?
                    </a>
                  </div>
                </div>
              </div>
            </body>
            </html>
          HTML
        end
      end
    end
  end
end
