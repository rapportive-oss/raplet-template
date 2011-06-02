require 'rubygems'
require 'bundler/setup'
require 'json'
require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require 'action_view'
require 'andand'

require File.join(File.dirname(__FILE__), 'user')
require File.join(File.dirname(__FILE__), 'request')


class Raplet < Sinatra::Base
  enable :sessions

  set :public, File.join(File.dirname(__FILE__), 'public')

  helpers do
    include Rack::Utils
    include ActionView::Helpers::DateHelper
    alias_method :h, :escape_html
  end

  # Handles a request to the raplet by an authenticated user.
  def raplet_request(user)
    # Remove 'uninteresting' query parameters (JSONP, cache busting and OAuth parameters)
    filtered_params = params.reject do |name, value|
      %w(callback oauth_token).include?(name.to_s) || (name.to_s =~ /\A_\d+\z/)
    end

    # The @request object encapsulates the Raplet's business logic.
    @request = Request.new(user, filtered_params.with_indifferent_access)

    # Render the response.erb template to form the HTML part of the raplet response.
    # The template can access the @request object.
    {
      :html => erb(:response),
      :css => File.read('views/style.css'),
      :js => File.read('views/script.js'),
      :status => 200
    }
  end


  # Returns a static hash of useful information about the Raplet.
  def metadata
    {
      :name => "My Custom Raplet",
      :description => "This is just a template. Customize it for your own purposes.",
      :welcome_text => %q{
        <p>Welcome to your new Raplet!</p>
        <p>This is the welcome text, which is displayed before a user installs the Raplet.
        You can use it to explain what the Raplet provides, and why the user might be
        interested in using it. You can include HTML for <em>formatting</em>.</p>
      },
      :provider_name => "Your name",
      :provider_url => "http://example.com",
      :config_url => "#{raplet_base_url}/config"
    }
  end

  # Message shown to user if they don't present a valid oauth_token.
  def access_denied
    {
      :html => 'Sorry, we cannot verify that you are a user. Please reinstall this Raplet.',
      :status => 401
    }
  end

  # Check that the configuration parameters have the expected values (this is important for
  # security, so that your Raplet can't inadvertently issue an OAuth tokens to an attacker).
  def check_config_params
    unless params[:redirect_uri] =~ %r{\Ahttps?://(rapportive\.com|rapportive\.jelzo\.com|localhost)(:\d+)?/raplets/} &&
           params[:response_type] == 'token' && params[:client_id] == 'rapportive'
      raise "invalid configuration parameters"
    end
  end

  # Base URL (excluding path) at which the Raplet was requested
  def raplet_base_url
    "#{request.scheme}://#{request.host}:#{request.port}"
  end

  # Convenience method for constructing a JSONP response from a Ruby hash.
  def jsonp_response(json)
    [
      200, # HTTP OK
      {'Content-Type' => 'text/javascript; charset=utf-8'},
      (params[:callback] || '') + '(' + JSON.generate(json) + ');'
    ]
  end


  # When you visit the base URL, redirect to a page on Rapportive that starts the Raplet
  # installation process. (This is not required by the API, it's just a nice extra touch)
  get "/" do
    redirect('https://rapportive.com/raplets?' + {:preset => raplet_base_url + '/raplet'}.to_query)
  end

  # Main Raplet endpoint
  get "/raplet" do
    if params[:show] == "metadata"
      jsonp_response(metadata)
    elsif user = User.first(:raplet_token => params[:oauth_token])
      jsonp_response(raplet_request(user))
    else
      jsonp_response(access_denied)
    end
  end

  # Configuration page. This page is opened in a popup window when the user installs the Raplet.
  # In this example, we render a form and require the user to submit it in order to complete the
  # Raplet installation. You can change it to do whatever is needed for your application, e.g.
  # authenticating the user or asking them for their account name.
  get "/config" do
    check_config_params
    erb(:config)
  end

  # When the configuration form is submitted, we create a new user for the Raplet, and any form
  # fields with a name of config[foo] are stored in a JSON blob on the user object. We then pass the
  # user's newly generated OAuth token to Rapportive by redirecting the user.
  post "/config" do
    check_config_params
    user = User.create(
      :raplet_token => ActiveSupport::SecureRandom.hex(16),
      :config => params[:config]
    )
    redirect(params[:redirect_uri] + '#' + {:access_token => user.raplet_token}.to_query)
  end
end
