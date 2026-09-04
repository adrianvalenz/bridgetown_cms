# frozen_string_literal: true

module BridgetownCms
  module RodauthTemplates
    # Custom login page template
    def self.login_page
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

              <%= rodauth.login_form_header %>

              <form method="post" action="<%= rodauth.login_path %>" class="space-y-4">
                <%= rodauth.csrf_tag %>

                <div>
                  <label for="login" class="block text-sm font-medium text-gray-700 mb-2">
                    Email
                  </label>
                  <input type="email" id="login" name="login" required autofocus
                         value="<%= rodauth.login_param %>"
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

                <% if rodauth.features.include?(:remember) %>
                <div class="flex items-center">
                  <input type="checkbox" id="remember" name="remember" value="t"
                         class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" />
                  <label for="remember" class="ml-2 block text-sm text-gray-700">
                    Remember me
                  </label>
                </div>
                <% end %>

                <button type="submit"
                        class="w-full px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                  Sign In
                </button>
              </form>

              <% if rodauth.features.include?(:reset_password) %>
              <div class="mt-4 text-sm text-center">
                <a href="<%= rodauth.reset_password_request_path %>" class="text-blue-600 hover:text-blue-800">
                  Forgot your password?
                </a>
              </div>
              <% end %>
            </div>
          </div>
        </body>
        </html>
      HTML
    end
  end
end
