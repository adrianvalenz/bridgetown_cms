module BridgetownCms
  class PostRoutes
    POST_DIRECTORY = File.expand_path("src/_posts", Bridgetown.configuration.root_dir)

    def self.route(r)
      # GET: Retrieve posts
      r.get "api", "posts" do
        posts = []

        Bridgetown.logger.info "Reading posts via API in #{POST_DIRECTORY}"

        Dir.glob("#{POST_DIRECTORY}/*.md").each do |filename|
          puts "Processing file: #{filename}"

          post_content = File.read(filename)
          front_matter, content = post_content.split("---\n", 3)[1..2]

          begin
            metadata = YAML.safe_load(front_matter, permitted_classes: [Time])
          rescue Psych::DisallowedClass => e
            puts "Error parsing YAML for file #{filename}: #{e.message}"
            next
          end

          # Add the posts to the posts array
          posts << {
            id: File.basename(filename),
            title: metadata["title"],
            date: metadata["date"],
            content:
          }
        end

        posts
      end

      # POST: Create a new post
      r.post "api", "posts" do
        new_post = r.params

        puts "🔔 Parsed new post params #{new_post}"

        if new_post[:title].nil? || new_post[:content].nil?
          response.status = 400
          { error: "Missing title or content" }
        else
          # Use the current date for the post file name
          date_str = Date.today.to_s
          post_filename = "#{date_str}-#{new_post["title"].downcase.gsub(" ", "-")}.md"
          post_filepath = File.join(POST_DIRECTORY, post_filename)

          # Create the front matter and content for the markdown file
          front_matter = {
            "layout" => "post",
            "title" => new_post["title"],
            "date" => Time.now
          }.to_yaml

          post_content = <<~MARKDOWN
          #{front_matter.strip}
          ---
          #{new_post["content"]}
          MARKDOWN

          File.write(post_filepath, post_content.strip)

          response.status = 201
          { message: "Post created successfully", filename: post_filename }
        end
      end

      # PUT: Update an existing post
      r.put "api/posts/:filename" do |filename|
        updated_post_params = r.params
        post_filepath = File.join(POST_DIRECTORY, filename) # '.src/_posts/'
        puts "🔔 Looking for file: #{post_filepath}"

        if File.exist?(post_filepath)
          post_content = File.read(post_filepath)

          front_matter, content = post_content.split("---\n", 3)[1..2]

          if front_matter
            metadata = YAML.safe_load(front_matter, permitted_classes: [Time])

            metadata["title"] = updated_post_params["title"] unless updated_post_params["title"].nil?
            metadata["date"] = Time.now

            updated_content = <<~MARKDOWN
            #{metadata.to_yaml.strip}
            ---
            #{updated_post_params["content"].to_s.strip.empty? ? content : updated_post_params["content"].strip}
            MARKDOWN

            File.write(post_filepath, updated_content.strip)

            response.status = 200
            { message: "Post updated successfully", filename: filename }
          else
            response.status = 400
            { error: "Invalid front matter" }
          end
        else
          response.status = 404
          { error: "Post not found " }
        end
      end

      # DELETE: Remove a post
      r.delete "api", "posts", String do |filename|
        post_filepath = File.join(POST_DIRECTORY, filename)
        if File.exist?(post_filepath)
          File.delete(post_filepath)
          response.status = 204
        else
          response.status = 404
          { error: "Post not found" }
        end
      end
    end
  end
end
