require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "serves the reference-inspired home page" do
    get root_path

    assert_response :success
    assert_select "h1", /Choisissez/
    assert_select "[data-controller~='budget']"
    assert_select "a", text: "Starter Pack"
    assert_select "a", text: "Pack Premium"
  end

  test "serves the linked marketing pages" do
    {
      about_path => "Rendre l'achat auto lisible",
      faq_path => "Questions frequentes",
      starter_pack_path => "Starter pack",
      pack_premium_path => "Pack Premium",
      contact_path => "Vous etes perdu"
    }.each do |path, heading|
      get path

      assert_response :success
      assert_select "body", /#{Regexp.escape(heading)}/
    end
  end
end
