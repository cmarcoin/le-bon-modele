require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "inquiry email is sent to the contact recipient with reply-to" do
    email = ContactMailer.inquiry(
      first_name: "Jean",
      email: "jean@example.com",
      message: "Je cherche une voiture familiale."
    )

    assert_equal [ ContactMailer::RECIPIENT ], email.to
    assert_equal [ "jean@example.com" ], email.reply_to
    assert_match(/Jean/, email.subject)
    assert_match(/Je cherche une voiture familiale/, email.body.encoded)
  end
end
