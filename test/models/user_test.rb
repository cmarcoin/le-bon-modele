require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin helper reflects role" do
    assert users(:admin).admin?
    assert_not users(:client).admin?
  end
end
