require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "inquiry email is sent to the contact recipient with reply-to" do
    inquiry = ContactInquiry.new(
      first_name: "Jean",
      email: "jean@example.com",
      message: "Je cherche une voiture familiale."
    )

    email = ContactMailer.inquiry(inquiry)

    assert_equal [ ContactMailer::RECIPIENT ], email.to
    assert_equal [ "jean@example.com" ], email.reply_to
    assert_match(/Jean/, email.subject)
    assert_match(/Je cherche une voiture familiale/, email.body.encoded)
  end
end
