ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    include ActiveJob::TestHelper

    # Windows does not support UNIXServer used by DRb parallelization.
    unless Gem.win_platform?
      # Use process-based parallelization to avoid shared-connection issues on PostgreSQL.
      parallelize(workers: :number_of_processors, with: :processes)
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
