require "test_helper"

class WwwToApexRedirectTest < ActiveSupport::TestCase
  setup do
    @app = ->(_env) { [ 200, { "Content-Type" => "text/plain" }, [ "ok" ] ] }
    @middleware = WwwToApexRedirect.new(@app)
  end

  test "redirects www apex host to https apex" do
    env = Rack::MockRequest.env_for("http://www.lebonmodele.fr/faq")
    status, headers, = @middleware.call(env)

    assert_equal 301, status
    assert_equal "https://lebonmodele.fr/faq", headers["Location"]
  end

  test "does not redirect apex host" do
    env = Rack::MockRequest.env_for("https://lebonmodele.fr/faq")
    status, _headers, body = @middleware.call(env)

    assert_equal 200, status
    assert_equal [ "ok" ], body
  end

  test "does not redirect health check on www" do
    env = Rack::MockRequest.env_for("http://www.lebonmodele.fr/up")
    status, = @middleware.call(env)

    assert_equal 200, status
  end
end
