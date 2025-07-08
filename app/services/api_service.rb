#
# ApiService is a base class for all service objects that need to make HTTP API calls.
# It includes HTTParty for making HTTP requests, and provides common error handling.
#
# All API-related service objects should inherit from this class to get:
#   - HTTParty integration
#   - Consistent error logging
#   - Safe GET helper method with rescue
#
# Example:
#   class WeatherService < ApiService
#     base_uri 'https://api.example.com'
#
#     def call
#       response = safe_get('/endpoint', query: { key: value })
#       ...
#     end
#   end
#
require 'httparty'

class ApiService < ApplicationService
  include HTTParty

  # safe_get wraps HTTParty.get with basic error rescue and logging.
  #
  # @param path [String] The relative path to request.
  # @param options [Hash] Options to pass to HTTParty (query, headers, etc).
  # @return [HTTParty::Response, nil] The response object or nil if error.
  def safe_get(path, options = {})
    self.class.get(path, options)
  rescue StandardError => e
    Rails.logger.error "[API ERROR] #{e.class}: #{e.message}"
    nil
  end
end
