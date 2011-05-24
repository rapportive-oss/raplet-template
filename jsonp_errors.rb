# Rack middleware which wraps HTTP error responses in JSONP, so that the client application can
# interpret them. (This is ugly because it breaks standard HTTP semantics, but as long as we have to
# use JSONP, we have no choice...)
class JsonpErrors
  def initialize(app)
    @app = app
  end

  # Generates a HTML string to include in the wrapped JSONP error. In development, includes a link
  # to the same URL with the callback parameter removed (and since requests without callback
  # parameter don't get JSONP-wrapped, you'll be able to see the original error page at that URL).
  def error_html(env)
    html = 'Sorry, an error occurred in the Raplet.'
    if ENV['RACK_ENV'] == 'development'
      request_url = env['rack.url_scheme'] + '://' + env['HTTP_HOST'] + env['REQUEST_URI']
      request_url.gsub! /([?&])callback=[^&]*&?/, '\1'
      html << %Q{ (<a href="#{request_url}">Stack trace</a>)}
    end
    "<p>#{html}</p>"
  end

  # Handles an incoming HTTP request.
  def call(env)
    # Pass the request through to the Sinatra application
    status, headers, response = @app.call(env)

    # If an error occurred processing the request, and it's a JSONP request (as indicated by the
    # presence of a callback=... query parameter), wrap the response up in a JSONP embrace.
    if (400..599).include?(status) && env['rack.request.query_hash'].include?('callback')
      response = env['rack.request.query_hash']['callback']
      response << '('
      response << JSON.generate(:status => status, :html => error_html(env), :css => 'a { color: rgb(42, 93, 176); }')
      response << ');'
      headers['Content-Length'] = response.length.to_s
      headers['Content-Type'] = 'text/javascript; charset=utf-8'
      status = 200
    end

    [status, headers, response]
  end

end
