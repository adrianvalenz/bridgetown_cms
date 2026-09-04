# Bridgetown CMS

A content management system for Bridgetown sites. Easily create, edit, and delete posts
using a simple web interface powered by HTMX and styled with Tailwind CSS.

Currently supports only markdown posts stored in the `src/_posts/` directory.

**Now with full authentication!** The plugin includes Rodauth-based authentication with user
management, role-based access control, and session management. Deploy confidently to production
with secure, password-protected admin access.



https://github.com/user-attachments/assets/97815512-4951-427c-972c-87d989ec96b1



## Features

- 🚀 **Plug-and-play** - Minimal setup required
- ⚡ **HTMX-powered** - No heavy JavaScript frameworks
- ✨ **Full CRUD** - Create, Read, Update, Delete posts
- 🔐 **Authentication** - Rodauth-based authentication with role-based access control
- 👥 **User Management** - Multi-user support with Admin and Author roles
- 🎨 **Beautiful UI** - Tailwind CSS styling
- 📝 **Markdown editor** - EasyMDE with live preview, syntax highlighting, and toolbar
- 🖼️ **Image uploads** - Upload images directly from the editor with auto-markdown insertion
- 💾 **Autosave** - Your work is automatically saved as you type
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

## Upgrading

To upgrade to the latest version of Bridgetown CMS:

### From GitHub (Most Common)

Since this plugin is hosted on GitHub (not RubyGems), make sure your Gemfile includes the `git:` source:

```ruby
gem "bridgetown_cms", git: "https://github.com/adrianvalenz/bridgetown_cms"
```

Then update to the latest version:

```shell
bundle update bridgetown_cms
```

Restart your server:

```shell
# Stop the server (Ctrl+C) and restart
bin/bridgetown start
```

### Using a Specific Version/Tag

To lock to a specific version tag, update your Gemfile:

```ruby
gem "bridgetown_cms", git: "https://github.com/adrianvalenz/bridgetown_cms", tag: "v0.2.0"
```

Or to track a specific branch:

```ruby
gem "bridgetown_cms", git: "https://github.com/adrianvalenz/bridgetown_cms", branch: "main"
```

Then run:

```shell
bundle update bridgetown_cms
bin/bridgetown start
```

### From Local Development

If you're developing locally:

```ruby
gem "bridgetown_cms", path: "../bridgetown_cms"
```

No update command needed - changes are reflected immediately (just restart the server).

### Checking Your Version

The version number is displayed in the bottom-right corner of the admin interface footer. Visit `/admin` to see which version you're currently running.

### Release Notes

See [CHANGELOG.md](https://github.com/adrianvalenz/bridgetown_cms/blob/main/CHANGELOG.md) for a complete list of changes in each version.

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
3. Add your content using the markdown editor
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

### Using the Markdown Editor

The editor includes a full-featured toolbar with:

- **Formatting**: Bold, italic, headings
- **Lists**: Ordered and unordered lists
- **Quotes**: Block quotes
- **Links**: Insert hyperlinks
- **Images**: Upload images directly (see below)
- **Preview**: Live preview and side-by-side mode
- **Fullscreen**: Distraction-free writing mode
- **Autosave**: Your work is automatically saved to localStorage

### Uploading Images

1. Click the image icon (📷) in the editor toolbar
2. Select an image from your computer
3. The image is uploaded to `src/images/uploads/`
4. Markdown syntax is automatically inserted: `![filename](/images/uploads/filename.jpg)`
5. Images are immediately viewable in the preview pane

**Supported formats**: JPG, PNG, GIF, WebP, and other common image formats

All changes trigger Bridgetown's live reload, so you'll see updates in real-time!

## Authentication & User Management

### First-Time Setup

When you first visit `/admin`, you'll be automatically redirected to the setup page where you can create your first admin account. After setup, you'll need to log in with your credentials.

### User Roles

- **Admin**: Full access to all features, can manage all posts
- **Author**: Can create and edit their own posts only

### Managing Users via Console

You can manage users programmatically using the Bridgetown console. This is useful for administrative tasks like creating users, resetting passwords, or managing roles.

#### Starting the Console

```shell
bin/bridgetown console
```

#### Load Required Classes

Once in the console, load the necessary classes:

```ruby
# First, require the main plugin
require 'bridgetown_cms'

# Then require the authentication modules
require 'bridgetown_cms/database'
require 'bridgetown_cms/roles'
require 'bcrypt'

# Get database connection
db = BridgetownCms::Database.connection
```

#### View All Users

```ruby
# List all users
db[:accounts].all

# Get user count
db[:accounts].count

# View users with their roles
db[:accounts].left_join(:cms_roles, account_id: :id).select_all.all
```

#### View Specific User

```ruby
# Find user by email
user = db[:accounts].where(email: 'user@example.com').first

# Find user by ID
user = db[:accounts].where(id: 1).first

# Get user's role
role = BridgetownCms::Roles.get_role(user[:id])
```

#### Create a New User

```ruby
# Create a new admin user
email = 'admin@example.com'
password = 'secure_password_here'
password_hash = BCrypt::Password.create(password)

# Insert account
account_id = db[:accounts].insert(
  email: email,
  password_hash: password_hash,
  created_at: Time.now,
  updated_at: Time.now
)

# Assign admin role
BridgetownCms::Roles.create_role(account_id, 'admin', 'Admin User')

# Or create an author user
account_id = db[:accounts].insert(
  email: 'author@example.com',
  password_hash: BCrypt::Password.create('password'),
  created_at: Time.now,
  updated_at: Time.now
)

BridgetownCms::Roles.create_role(account_id, 'author', 'Content Author')
```

#### Update User

```ruby
# Update user email
db[:accounts].where(id: 1).update(
  email: 'newemail@example.com',
  updated_at: Time.now
)

# Update user password
new_password_hash = BCrypt::Password.create('new_password')
db[:accounts].where(id: 1).update(
  password_hash: new_password_hash,
  updated_at: Time.now
)

# Update user role
BridgetownCms::Roles.update_role(1, 'admin', 'Super Admin')
```

#### Delete User

```ruby
# Delete user and their role
user_id = 1

# First delete the role
db[:cms_roles].where(account_id: user_id).delete

# Then delete the account
db[:accounts].where(id: user_id).delete

# Confirm deletion
db[:accounts].where(id: user_id).count  # Should return 0
```

#### Check User Permissions

```ruby
# Check if user is admin
user_id = 1
BridgetownCms::Roles.admin?(user_id)  # Returns true or false

# Get user's role
BridgetownCms::Roles.get_role(user_id)  # Returns role hash
```

#### Find Users by Role

```ruby
# Find all admins
admins = db[:cms_roles].where(role: 'admin').select(:account_id).all
admin_ids = admins.map { |r| r[:account_id] }
db[:accounts].where(id: admin_ids).all

# Find all authors
authors = db[:cms_roles].where(role: 'author').select(:account_id).all
author_ids = authors.map { |r| r[:account_id] }
db[:accounts].where(id: author_ids).all
```

#### Bulk Operations

```ruby
# Create multiple users at once
users = [
  { email: 'user1@example.com', role: 'admin', name: 'User 1' },
  { email: 'user2@example.com', role: 'author', name: 'User 2' },
  { email: 'user3@example.com', role: 'author', name: 'User 3' }
]

users.each do |user_data|
  account_id = db[:accounts].insert(
    email: user_data[:email],
    password_hash: BCrypt::Password.create('default_password'),
    created_at: Time.now,
    updated_at: Time.now
  )
  BridgetownCms::Roles.create_role(account_id, user_data[:role], user_data[:name])
end

# View results
db[:accounts].count
```

#### Database Backup

```ruby
# Export all users to a hash
users_backup = db[:accounts].left_join(:cms_roles, account_id: :id).select_all.all

# Save to a file
require 'json'
File.write('users_backup.json', JSON.pretty_generate(users_backup))
```

#### Useful Database Queries

```ruby
# Get total user count
db[:accounts].count

# Get users created in the last 7 days
db[:accounts].where { created_at > Time.now - (7 * 24 * 60 * 60) }.all

# Get users by email domain
db[:accounts].where(Sequel.like(:email, '%@example.com')).all

# List all tables in the database
db.tables

# View table schema
db.schema(:accounts)
db.schema(:cms_roles)
```

### Security Notes

- Always use strong passwords when creating users via console
- The database file is stored in `config/bridgetown_cms.db` and should be gitignored
- Password hashes are created using BCrypt for security
- Session keys are encrypted and managed by Rodauth

## Permalink Configuration

The plugin automatically generates "View Post" links in the admin panel based on your Bridgetown permalink configuration. It supports all four built-in permalink styles:

### Permalink Styles

Configure your permalink style in `config/initializers.rb`:

```ruby
Bridgetown.configure do |config|
  permalink "simple"  # or "simple_ext", "pretty", "pretty_ext"
end
```

Or in `bridgetown.config.yml` (for older Bridgetown sites):

```yaml
permalink: simple
```

**Available Styles:**

| Style | Format | Example URL |
|-------|--------|------------|
| `simple` | `/:categories/:slug/` | `/updates/welcome-to-bridgetown/` |
| `simple_ext` | `/:categories/:slug.html` | `/updates/welcome-to-bridgetown.html` |
| `pretty` | `/:categories/:year/:month/:day/:slug/` | `/updates/2025/10/12/welcome-to-bridgetown/` |
| `pretty_ext` | `/:categories/:year/:month/:day/:slug.html` | `/updates/2025/10/12/welcome-to-bridgetown.html` |

**Notes:**
- The plugin automatically detects your permalink setting from **either** configuration file
- If no permalink style is configured, the plugin defaults to `pretty`
- Categories from your post's front matter are automatically included in URLs
- **Configuration changes require a server restart** to take effect (stop with `Ctrl+C` and run `bin/bridgetown start` again)

## How It Works

- **Backend**: Ruby/Roda routes with file-based storage
- **Authentication**: Rodauth with SQLite database and BCrypt password hashing
- **Frontend**: HTMX for dynamic interactions (no page refreshes)
- **Editor**: EasyMDE markdown editor with live preview and autosave
- **Styling**: Tailwind CSS (loaded via CDN)
- **Content**: Standard Bridgetown markdown posts with YAML frontmatter
- **Storage**: Posts saved to `src/_posts/`, images to `src/images/uploads/`
- **Database**: User accounts and roles in `config/bridgetown_cms.db` (SQLite)
- **Editing**: You can edit the markdown directly from the files and it will reflect in the admin panel

## Requirements

- Bridgetown 2.0+ (or 1.x with SSR/Roda routes)
- Ruby 3.0+
- SSR (Server-Side Rendering) must be enabled

**Note:** The plugin works with permalink settings in either `config/initializers.rb` (Bridgetown 2.0+) or `bridgetown.config.yml` (all versions). Bridgetown automatically merges configuration from all sources.

## Plugin Architecture

The plugin consists of:

### Core Modules
- **`lib/bridgetown_cms/admin_routes.rb`** - All CRUD operations and HTML rendering
- **`layouts/bridgetown_cms/admin_layout.erb`** - Admin interface layout with HTMX/Tailwind
- **`content/bridgetown_cms/admin.md`** - Admin dashboard page
- **`lib/bridgetown_cms/builder.rb`** - Plugin initialization
- **`bridgetown.automation.rb`** - Installation automation script

### Authentication Modules
- **`lib/bridgetown_cms/database.rb`** - SQLite database management with auto-migrations
- **`lib/bridgetown_cms/rodauth_config.rb`** - Rodauth authentication configuration
- **`lib/bridgetown_cms/roles.rb`** - Role-based access control (Admin/Author)
- **`lib/bridgetown_cms/auth_helpers.rb`** - Authentication helper methods

### Database
- **`config/bridgetown_cms.db`** - SQLite database (auto-created, gitignored)
- Tables: `accounts`, `cms_roles`, `account_password_reset_keys`, `account_remember_keys`

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
- [x] Image upload capability
- [x] Rich text editor (EasyMDE with markdown)
- [x] User authentication and roles (Rodauth-based)
- [ ] User management UI in admin panel
- [ ] Support for custom post types and formats
- [ ] Draft/publish workflow
- [ ] Category and tag management
- [ ] Drag-and-drop image uploads

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
