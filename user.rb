require 'datamapper'
require 'dm-core'
require 'dm-types'

# ENV["DATABASE_URL"] is pre-defined on Heroku. In other hosting environments, please configure this
# to point at your database. If undefined, we fall back to SQLite (which is fine for development).
DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{File.expand_path(File.dirname(__FILE__))}/raplet.sqlite3")

# Log verbosely
DataMapper::Logger.new($stdout, :debug)

# Database model object to represend one installed instance of the Raplet. Use it to store any
# per-user information required by your raplet. An installation is typically looked up by its OAuth
# token.
class User
  include DataMapper::Resource

  property :id, Serial
  property :raplet_token, String, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :config, DataMapper::Property::Json

  # ...add more columns here, as required by your Raplet.


  # The user may have set configuration parameters during the installation of the Raplet
  # (see the form in views/config.erb); these are stored as a JSON blob in the config property.
  # We can also expose configuration parameters through convenience methods, for example:
  def account_name
    config.andand["account_name"]
  end
end


# Automatically create/alter database table to match the schema declared above.
DataMapper.auto_upgrade!
