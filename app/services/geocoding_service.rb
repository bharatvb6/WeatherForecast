# GeocodingService is a service object to convert
# an address string into lat/lon and zip code data
# using an external geocoding API.
#
# Usage:
#   result = GeocodingService.call("1600 Amphitheatre Parkway, Mountain View, CA")
#   => { lat: "...", lon: "...", zip: "..." } or nil
#
class GeocodingService < ApiService
  base_uri 'https://maps.googleapis.com/maps/api/geocode'

  def initialize(address)
    @address = address
    @api_key = ENV['GOOGLE_GEOCODING_API_KEY']
  end

  def call
    response = safe_get('/json', query: {
      address: @address,
      key: @api_key
    })

    return nil unless response&.success?

    location_data = response.parsed_response["results"].first
    return nil unless location_data

    {
      lat: location_data["geometry"]["location"]["lat"],
      lon: location_data["geometry"]["location"]["lng"],
      address: location_data["formatted_address"],
      zip: extract_zip_code(location_data)
    }
  rescue => e
    Rails.logger.error "Geocoding error: #{e.message}"
    nil
  end

  private

  def extract_zip_code(location_data)
    components = location_data["address_components"]
    zip_component = components.find { |c| c["types"].include?("postal_code") }
    zip_component&.dig("long_name")
  end
end
