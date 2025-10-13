# Bridgetown CMS

A content management system for Bridgetown sites. Easily create, edit, and delete posts
using a simple web interface powered by HTMX and styled with Tailwind CSS.

Currently supports only markdown posts stored in the `src/_posts/` directory.

This plugin is intended to be used locally by developers or content creators. The assumption
is that the site will be hosted as a static site. So any attempt to access the admin panel 
in production will not work. Future plans will hopefully include authentication and user roles.

## Features

- 🚀 **Plug-and-play** - Minimal setup required
- ⚡ **HTMX-powered** - No heavy JavaScript frameworks
- ✨ **Full CRUD** - Create, Read, Update, Delete posts
- 🎨 **Beautiful UI** - Tailwind CSS styling
- 📝 **Markdown support** - Works with standard Bridgetown posts
- 🔄 **Live reload** - Changes appear immediately in your site

## Installation

### Quick Setup (Recommended)

1. **Add to your Gemfile:**

```ruby
gem "bridgetown_cms", git: "https://github.com/adrianvalenz/bridgetown_cms"

# Or for local development:
# gem "bridgetown_cms", path: "../bridgetown_cms"
```

2. **Install and run automation:**

```shell
bundle install
bin/bridgetown apply https://github.com/adrianvalenz/bridgetown_cms
```

The automation script will automatically:
- Create `server/routes/admin.rb` (bridge file for routes)
- Add `init :bridgetown_cms` to your initializers
- Add `init :ssr` to your initializers (required for routes)

These are the only changes you'll need to make on your site! Everything else is handled by the plugin.

3. **Start your server:**

```shell
bin/bridgetown start
```

4. **Access the admin panel:**

Visit `http://localhost:4000/admin` 🎉

### Manual Setup

If you prefer manual setup or the automation fails:

1. Add to your Gemfile and run `bundle install`

2. Create `server/routes/admin.rb`:

```ruby
require "bridgetown_cms/admin_routes"

class Routes::Admin < Bridgetown::Rack::Routes
  route do |r|
    BridgetownCms::AdminRoutes.define_routes(r)
  end
end
```

3. Add to `config/initializers.rb`:

```ruby
init :bridgetown_cms
init :ssr  # Required for routes
```

## Usage

### Creating an Article

1. Visit `/admin` in your browser
2. Fill in the article title (required)
3. Add your content in markdown format
4. Click "Create Article"
5. Your article is saved to `src/_posts/YYYY-MM-DD-slug.md`

### Editing an Article

1. Click the "Edit" button next to any article in the list
2. Modify the title or content
3. Click "Update Article"
4. Changes are saved immediately

### Deleting an Article

1. Click the "Delete" button next to any article
2. Confirm the deletion
3. The file is permanently removed from `src/_posts/`

All changes trigger Bridgetown's live reload, so you'll see updates in real-time!

## How It Works

- **Backend**: Ruby/Roda routes with file-based storage
- **Frontend**: HTMX for dynamic interactions (no page refreshes)
- **Styling**: Tailwind CSS (loaded via CDN)
- **Content**: Standard Bridgetown markdown posts with YAML frontmatter
- **Storage**: Files saved to `src/_posts/` directory
- **Editing**: You can edit the markdown directly from the files and it will reflect in the admin panel

## Requirements

- Bridgetown 2.0+
- Ruby 3.0+
- SSR (Server-Side Rendering) must be enabled

## Plugin Architecture

The plugin consists of:

- **`lib/bridgetown_cms/admin_routes.rb`** - All CRUD operations and HTML rendering
- **`layouts/bridgetown_cms/admin_layout.erb`** - Admin interface layout with HTMX/Tailwind
- **`content/bridgetown_cms/admin.md`** - Admin dashboard page
- **`lib/bridgetown_cms/builder.rb`** - Plugin initialization
- **`bridgetown.automation.rb`** - Installation automation script

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Clone the fork using `git clone` to your local development machine.
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## License

MIT

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

## Roadmap

Future enhancements:
- [ ] Image upload capability
- [ ] Support for custom post types and formats
- [ ] Rich text editor
- [ ] User authentication and roles
- [ ] Draft/publish workflow
- [ ] Category and tag management

---

<!-- ## Releasing (you can delete this section in your own plugin repo) -->
<!---->
<!-- To release a new version of the plugin, simply bump up the version number in both `version.rb` and -->
<!-- `package.json`, and then run `script/release`. This will require you to have a registered account -->
<!-- with both the [RubyGems.org](https://rubygems.org) and [NPM](https://www.npmjs.com) registries. -->
<!-- You can optionally remove the `package.json` and `frontend` folder if you don't need to package frontend -->
<!-- assets for Webpack. -->
<!---->
<!-- If you run into any problems or need further guidance, please check out our [Bridgetown community resources](https://www.bridgetownrb.com/docs/community) -->
<!-- where friendly folks are standing by to help you build and release your plugin or theme. -->
<!---->
<!-- **NOTE:** make sure you add the `bridgetown-plugin` [topic](https://github.com/topics/bridgetown-plugin) to your -->
<!-- plugin's GitHub repo so the plugin or theme will show up on [Bridgetown's official Plugin Directory](https://www.bridgetownrb.com/plugins)! (There may be a day or so delay before you see it appear.) -->
