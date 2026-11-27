require "test_helper"

class SiteCopyTest < ActiveSupport::TestCase
  test "fetch returns the stored value then the default" do
    assert_equal "fallback", SiteCopy.fetch("missing.key", "fallback")

    # Use find_or_initialize_by to avoid duplicate key error when SiteCopy is pre-seeded
    copy = SiteCopy.find_or_initialize_by(key: "home.hero_title")
    copy.assign_attributes(label: "Slogan", group: "home", value: "Nouveau slogan")
    copy.save!

    assert_equal "Nouveau slogan", SiteCopy.fetch("home.hero_title", "fallback")
  end

  test "seed creates missing copies without overwriting edited values" do
    SiteCopy.seed!
    copy = SiteCopy.find_by!(key: "home.hero_title")
    copy.update!(value: "Texte modifié")

    SiteCopy.seed!

    assert_equal "Texte modifié", copy.reload.value
    assert SiteCopy.exists?(key: "contact.phone_charles")
    assert SiteCopy.exists?(key: "contact.hours")
  end
end
