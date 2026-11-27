require "test_helper"

class TypographicApostrophesTest < ActionDispatch::IntegrationTest
  test "public pages use typographic apostrophes in visible French text" do
    pages_to_test = [
      "/",
      "/starter-pack",
      "/pack-premium",
      "/cgv",
      "/mentions-legales",
      "/politique-de-confidentialite"
    ]

    pages_to_test.each do |page_path|
      get page_path
      assert_response :success, "Failed to load #{page_path}"

      # Get the response body
      body = response.body

      # Remove script and style tags
      body_without_scripts = body.gsub(/<script[^>]*>.*?<\/script>/m, "")
      body_without_styles = body_without_scripts.gsub(/<style[^>]*>.*?<\/style>/m, "")

      # Remove HTML tags to get visible text
      visible_text = body_without_styles.gsub(/<[^>]+>/, " ")

      # Decode HTML entities
      visible_text = CGI.unescapeHTML(visible_text)

      # Check for straight apostrophes in French contractions (word'word pattern)
      straight_apostrophes = visible_text.scan(/\w'\w/)

      assert_empty straight_apostrophes,
                   "Found #{straight_apostrophes.length} straight apostrophes in visible text on #{page_path}: #{straight_apostrophes.first(5).join(', ')}"
    end
  end
end
