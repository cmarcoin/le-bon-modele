class AppUrl
  def self.base
    host = ENV.fetch("APP_HOST", "localhost:3000")
    protocol = host.include?("localhost") ? "http" : "https"
    "#{protocol}://#{host}"
  end
end
