class WwwToApexRedirect
  APEX_HOST = "lebonmodele.fr"
  WWW_HOST = "www.lebonmodele.fr"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) if request.path == "/up"
    return @app.call(env) unless request.host.to_s.downcase == WWW_HOST

    location = "https://#{APEX_HOST}#{request.fullpath}"
    [ 301, { "Location" => location, "Content-Type" => "text/plain" }, [ "Redirecting to #{location}" ] ]
  end
end
