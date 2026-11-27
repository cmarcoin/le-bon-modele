ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
    include ActionMailer::TestHelper

    # Ensure SiteCopy defaults are seeded before tests run
    # Use a lock to prevent duplicate key errors from parallel workers
    parallelize_setup do |worker|
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(123456789)")
      begin
        # Only seed if not already seeded
        SiteCopy.seed! if SiteCopy.count == 0
      ensure
        ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(123456789)")
      end
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
