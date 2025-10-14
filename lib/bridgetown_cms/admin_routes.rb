# frozen_string_literal: true

require 'fileutils'
require 'date'
require 'yaml'

module BridgetownCms
  class AdminRoutes
    # Define the posts directory relative to the Bridgetown site root
    POSTS_DIRECTORY = "src/_posts"
    IMAGES_DIRECTORY = "src/images/uploads"

    # Helper method to load all articles
    def self.load_articles
      articles = []
      posts_path = File.join(Bridgetown.configuration.root_dir, POSTS_DIRECTORY)

      Dir.glob("#{posts_path}/*.md").each do |filename|
        begin
          post_content = File.read(filename)
          front_matter, content = post_content.split("---\n", 3)[1..2]
          metadata = YAML.safe_load(front_matter, permitted_classes: [Time])

          articles << {
            id: File.basename(filename),
            title: metadata["title"],
            date: metadata["date"],
            categories: metadata["categories"],
            content: content&.strip
          }
        rescue => e
          next
        end
      end

      # Sort by date, newest first
      articles.sort_by! { |a| a[:date] || Time.at(0) }.reverse!
      articles
    end

    # Helper method to convert article to URL path
    # Supports all Bridgetown permalink styles: simple, simple_ext, pretty, pretty_ext
    # Handles categories in permalinks as per Bridgetown defaults
    # Example: {id: "2024-01-15-my-post-title.md", categories: "updates", date: Time} -> "/updates/2024/01/15/my-post-title/" (for pretty style)
    def self.article_id_to_url(article)
      # Handle both Hash and article ID string for backwards compatibility
      if article.is_a?(Hash)
        article_id = article[:id]
        categories = article[:categories]
        article_date = article[:date]
      else
        article_id = article
        categories = nil
        article_date = nil
      end

      # Remove .md extension
      filename_without_ext = article_id.sub(/\.md$/, '')

      # Split by hyphen to extract date and slug
      parts = filename_without_ext.split('-')

      # Extract date parts and slug
      # Use the front matter date if available (Bridgetown uses this for URL generation)
      # Otherwise fall back to filename date
      if parts.length >= 4
        if article_date
          # Use actual date from front matter (matches Bridgetown's behavior)
          year = article_date.strftime("%Y")
          month = article_date.strftime("%m")
          day = article_date.strftime("%d")
        else
          # Fall back to filename date
          year = parts[0]
          month = parts[1]
          day = parts[2]
        end
        slug = parts[3..-1].join('-')

        # Build categories path if categories exist
        # Categories can be a string or array in Bridgetown
        categories_path = ""
        if categories
          if categories.is_a?(Array)
            categories_path = categories.join('/') + '/'
          else
            categories_path = categories.to_s + '/'
          end
        end

        # Get permalink style from Bridgetown configuration
        # In SSR mode, we need to use Bridgetown::Current.site.config instead of Bridgetown.configuration
        config = defined?(Bridgetown::Current.site) && Bridgetown::Current.site ?
                   Bridgetown::Current.site.config :
                   Bridgetown.configuration

        # Default to "pretty" if not configured
        permalink_style = config.permalink || "pretty"

        case permalink_style.to_s
        when "simple"
          # Format: /:categories/:slug/
          "/#{categories_path}#{slug}/"
        when "simple_ext"
          # Format: /:categories/:slug.* (keeps extension like .html)
          "/#{categories_path}#{slug}.html"
        when "pretty"
          # Format: /:categories/:year/:month/:day/:slug/
          "/#{categories_path}#{year}/#{month}/#{day}/#{slug}/"
        when "pretty_ext"
          # Format: /:categories/:year/:month/:day/:slug.* (keeps extension like .html)
          "/#{categories_path}#{year}/#{month}/#{day}/#{slug}.html"
        else
          # Fallback to pretty style for unknown configurations
          "/#{categories_path}#{year}/#{month}/#{day}/#{slug}/"
        end
      else
        # Fallback if format doesn't match expected pattern
        "/#{filename_without_ext}/"
      end
    end

    # Helper method to render articles list HTML
    def self.render_articles_list(articles)
      if articles.empty?
        return <<~HTML
          <div id="articles-list">
            <div class="text-center py-12 bg-gray-50 rounded-lg border-2 border-dashed border-gray-300">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">No articles</h3>
              <p class="mt-1 text-sm text-gray-500">Get started by creating a new article above.</p>
            </div>
          </div>
        HTML
      end

      rows = articles.map do |article|
        preview = article[:content]&.slice(0, 100) || ""
        preview += "..." if article[:content]&.length.to_i > 100
        date_str = article[:date]&.strftime("%B %d, %Y") || "No date"

        <<~HTML
          <tr id="article-#{article[:id]}" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900">#{article[:title]}</div>
              <div class="text-sm font-medium text-gray-900"><a href="#{AdminRoutes.article_id_to_url(article)}" class="text-blue-600 hover:text-blue-900" target="_blank">View Post</a></div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-500">#{date_str}</div>
            </td>
            <td class="px-6 py-4">
              <div class="text-sm text-gray-500 truncate max-w-md">#{preview}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button class="text-blue-600 hover:text-blue-900 mr-4"
                      hx-get="/admin/articles/#{article[:id]}/edit"
                      hx-target="#article-form-container"
                      hx-swap="innerHTML">
                Edit
              </button>
              <button class="text-red-600 hover:text-red-900"
                      hx-delete="/admin/api/articles/#{article[:id]}"
                      hx-confirm="Are you sure you want to delete '#{article[:title]}'?"
                      hx-target="#articles-list-container"
                      hx-swap="innerHTML">
                Delete
              </button>
            </td>
          </tr>
        HTML
      end.join

      <<~HTML
        <div id="articles-list">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Content Preview</th>
                  <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                #{rows}
              </tbody>
            </table>
          </div>
        </div>
      HTML
    end

    # Helper method to render article form HTML
    def self.render_article_form(article = nil)
      is_edit = !article.nil?
      title = article ? article[:title] : ""
      content = article ? article[:content] : ""
      action = is_edit ? "/admin/api/articles/#{article[:id]}" : "/admin/api/articles"
      method = is_edit ? "hx-put" : "hx-post"
      button_text = is_edit ? "Update Article" : "Create Article"

      # For edit mode, target both the articles list and the form container
      # For create mode, only target the articles list and reset the form
      if is_edit
        hx_target = "#articles-list-container"
        hx_after_request = "if(event.detail.successful) { htmx.ajax('GET', '/admin/article-form', {target: '#article-form-container', swap: 'innerHTML'}); }"
      else
        hx_target = "#articles-list-container"
        hx_after_request = "if(event.detail.successful) { this.reset(); if(window.currentEditor) { window.currentEditor.value(''); } }"
      end

      <<~HTML
        <div id="article-form">
          <form id="article-form-element"
                #{method}="#{action}"
                hx-target="#{hx_target}"
                hx-swap="innerHTML"
                hx-on::after-request="#{hx_after_request}">
            <div class="mb-4">
              <label for="title" class="block text-sm font-medium text-gray-700 mb-2">
                Article Title <span class="text-red-500">*</span>
              </label>
              <input type="text" id="title" name="title" value="#{title}" required
                     class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                     placeholder="Enter article title..." />
            </div>
            <div class="mb-4">
              <label for="content" class="block text-sm font-medium text-gray-700 mb-2">Content (Markdown)</label>
              <textarea id="content" name="content">#{content}</textarea>
            </div>
            <div class="flex items-center justify-between">
              <div class="flex space-x-3">
                <button type="submit"
                        class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                  #{button_text}
                </button>
                #{is_edit ? '<button type="button" hx-get="/admin/article-form" hx-target="#article-form-container" hx-swap="innerHTML" class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">Cancel</button>' : ''}
              </div>
              #{is_edit ? '' : '<button type="button" onclick="document.getElementById(\'article-form-element\').reset(); if(window.currentEditor) { window.currentEditor.codemirror.setValue(\'\'); window.currentEditor.clearAutosavedValue(); }" class="text-sm text-gray-500 hover:text-gray-700">Clear Form</button>'}
            </div>
          </form>
        </div>
      HTML
    end

    def self.define_routes(r)
      # Mount all admin routes under /admin
      r.on "admin" do
            # HTML endpoints for HTMX (return HTML fragments)
            r.on "articles" do
              # GET /admin/articles - Return HTML list of articles
              r.is do
                r.get do
                  articles = AdminRoutes.load_articles
                  AdminRoutes.render_articles_list(articles)
                end
              end

              # GET /admin/articles/:filename/edit - Return form with article data
              r.on String, "edit" do |filename|
                r.get do
                  posts_path = File.join(Bridgetown.configuration.root_dir, POSTS_DIRECTORY)
                  article_filepath = File.join(posts_path, filename)

                  if File.exist?(article_filepath)
                    post_content = File.read(article_filepath)
                    front_matter, content = post_content.split("---\n", 3)[1..2]
                    metadata = YAML.safe_load(front_matter, permitted_classes: [Time])

                    article = {
                      id: filename,
                      title: metadata["title"],
                      date: metadata["date"],
                      categories: metadata["categories"],
                      content: content&.strip
                    }

                    # Render form with article data
                    AdminRoutes.render_article_form(article)
                  else
                    "<div class='text-red-600'>Article not found</div>"
                  end
                end
              end
            end

            # GET /admin/article-form - Return empty form (for cancel button)
            r.get "article-form" do
              AdminRoutes.render_article_form
            end

            # API endpoints for CRUD operations
            r.on "api" do
              # Image upload endpoint
              r.on "upload-image" do
                r.post do
                  file = r.params["image"]

                  if file && file[:tempfile]
                    images_path = File.join(Bridgetown.configuration.root_dir, IMAGES_DIRECTORY)
                    FileUtils.mkdir_p(images_path) unless Dir.exist?(images_path)

                    # Generate unique filename with timestamp to avoid conflicts
                    timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
                    original_filename = file[:filename]
                    ext = File.extname(original_filename)
                    base = File.basename(original_filename, ext)
                    # Sanitize filename
                    safe_base = base.downcase.gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-")
                    new_filename = "#{timestamp}-#{safe_base}#{ext}"

                    file_path = File.join(images_path, new_filename)

                    # Save the file
                    File.open(file_path, 'wb') do |f|
                      f.write(file[:tempfile].read)
                    end

                    # Return the path relative to the site root for markdown
                    image_url = "/images/uploads/#{new_filename}"

                    r.response.headers["Content-Type"] = "application/json"
                    { success: true, url: image_url, filename: new_filename }.to_json
                  else
                    r.response.status = 400
                    r.response.headers["Content-Type"] = "application/json"
                    { success: false, error: "No file provided" }.to_json
                  end
                end
              end

              r.on "articles" do
                # GET /admin/api/articles - List all articles
                r.get do
                  articles = []
                  posts_path = File.join(Bridgetown.configuration.root_dir, POSTS_DIRECTORY)

                  Bridgetown.logger.info "Reading articles from: #{posts_path}"

                  Dir.glob("#{posts_path}/*.md").each do |filename|
                    begin
                      post_content = File.read(filename)
                      front_matter, content = post_content.split("---\n", 3)[1..2]

                      metadata = YAML.safe_load(front_matter, permitted_classes: [Time])

                      articles << {
                        id: File.basename(filename),
                        title: metadata["title"],
                        date: metadata["date"],
                        categories: metadata["categories"],
                        content: content&.strip
                      }
                    rescue => e
                      Bridgetown.logger.warn "Error processing file #{filename}: #{e.message}"
                      next
                    end
                  end

                  # Sort by date, newest first
                  articles.sort_by! { |a| a[:date] || Time.at(0) }.reverse!

                  response.headers["Content-Type"] = "application/json"
                  articles.to_json
                end

                # POST /admin/api/articles - Create new article
                r.post do
                  new_article = r.params

                  if new_article["title"].nil? || new_article["title"].strip.empty?
                    "<div class='text-red-600 p-4 bg-red-50 rounded-lg'>Error: Title is required</div>"
                  else
                    posts_path = File.join(Bridgetown.configuration.root_dir, POSTS_DIRECTORY)
                    FileUtils.mkdir_p(posts_path) unless Dir.exist?(posts_path)

                    # Create filename from date and title
                    date_str = Date.today.to_s
                    slug = new_article["title"].downcase.gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-")
                    article_filename = "#{date_str}-#{slug}.md"
                    article_filepath = File.join(posts_path, article_filename)

                    # Create front matter
                    front_matter = {
                      "layout" => "post",
                      "title" => new_article["title"],
                      "date" => Time.now
                    }.to_yaml

                    # Build the markdown file content
                    article_content = <<~MARKDOWN
                      #{front_matter.strip}
                      ---
                      #{new_article["content"] || ""}
                    MARKDOWN

                    File.write(article_filepath, article_content.strip)

                    # Return updated articles list HTML
                    articles = AdminRoutes.load_articles
                    AdminRoutes.render_articles_list(articles)
                  end
                end

                # Handle individual article operations
                r.on String do |filename|
                  posts_path = File.join(Bridgetown.configuration.root_dir, POSTS_DIRECTORY)
                  article_filepath = File.join(posts_path, filename)

                  # GET /admin/api/articles/:filename - Get single article
                  r.get do
                    if File.exist?(article_filepath)
                      post_content = File.read(article_filepath)
                      front_matter, content = post_content.split("---\n", 3)[1..2]

                      metadata = YAML.safe_load(front_matter, permitted_classes: [Time])

                      response.headers["Content-Type"] = "application/json"
                      {
                        id: filename,
                        title: metadata["title"],
                        date: metadata["date"],
                        categories: metadata["categories"],
                        content: content&.strip
                      }.to_json
                    else
                      response.status = 404
                      response.headers["Content-Type"] = "application/json"
                      { error: "Article not found" }.to_json
                    end
                  end

                  # PUT /admin/api/articles/:filename - Update article
                  r.put do
                    if File.exist?(article_filepath)
                      updated_params = r.params

                      post_content = File.read(article_filepath)
                      front_matter, content = post_content.split("---\n", 3)[1..2]

                      if front_matter
                        metadata = YAML.safe_load(front_matter, permitted_classes: [Time])

                        # Update metadata
                        metadata["title"] = updated_params["title"] unless updated_params["title"].nil?
                        # This will update the date to now on each edit; uncomment if desired
                        # metadata["date"] = Time.now
                        #

                        # Use new content if provided, otherwise keep existing
                        new_content = updated_params["content"]&.strip&.empty? ? content : updated_params["content"]

                        updated_content = <<~MARKDOWN
                          #{metadata.to_yaml.strip}
                          ---
                          #{new_content&.strip}
                        MARKDOWN

                        File.write(article_filepath, updated_content.strip)

                        # Return updated articles list HTML
                        articles = AdminRoutes.load_articles
                        AdminRoutes.render_articles_list(articles)
                      else
                        "<div class='text-red-600 p-4 bg-red-50 rounded-lg'>Error: Invalid front matter</div>"
                      end
                    else
                      "<div class='text-red-600 p-4 bg-red-50 rounded-lg'>Error: Article not found</div>"
                    end
                  end

                  # DELETE /admin/api/articles/:filename - Delete article
                  r.delete do
                    if File.exist?(article_filepath)
                      File.delete(article_filepath)

                      # Return updated articles list HTML
                      articles = AdminRoutes.load_articles
                      AdminRoutes.render_articles_list(articles)
                    else
                      "<div class='text-red-600 p-4 bg-red-50 rounded-lg'>Error: Article not found</div>"
                    end
                  end
                end
              end
            end
      end
    end
  end
end
