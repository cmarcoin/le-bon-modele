require "test_helper"

class ContactSubmissionTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "contact page renders the form" do
    get contact_path

    assert_response :success
    assert_select "form[action=?]", submit_contact_path
    assert_select "input[name='contact_inquiry[first_name]']"
  end

  test "valid contact submission enqueues an email" do
    assert_enqueued_emails 1 do
      post submit_contact_path, params: {
        contact_inquiry: {
          first_name: "Jean",
          email: "jean@example.com",
          message: "Je cherche une voiture familiale."
        }
      }
    end

    assert_redirected_to contact_path
    assert_equal "Merci, votre message a bien été envoyé. Nous vous répondrons rapidement.", flash[:notice]
  end

  test "contact submission with honeypot filled is rejected" do
    assert_no_enqueued_emails do
      post submit_contact_path, params: {
        contact_inquiry: {
          first_name: "Jean",
          email: "jean@example.com",
          message: "Spam",
          company: "Evil Corp"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "contact submission with missing fields shows errors" do
    assert_no_enqueued_emails do
      post submit_contact_path, params: {
        contact_inquiry: {
          first_name: "",
          email: "invalid",
          message: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form[action=?]", submit_contact_path
  end
end
