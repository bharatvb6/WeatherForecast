#
# WeatherService fetches weather forecast data from OpenWeatherMap API.
#
# Usage:
#   result = WeatherService.call(lat, lon)
#   => { temperature: 25.3, high: 28, low: 21, description: "clear sky" }
#
# This service inherits from ApiService, so it can use `safe_get` for API calls.
#
class WeatherService < ApiService
  base_uri 'https://api.openweathermap.org/data/2.5'

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
    @api_key = ENV['WEATHER_API_KEY']
  end

  def call
    response = safe_get('/weather', query: {
      lat: @lat,
      lon: @lon,
      appid: @api_key,
      units: 'metric'
    })

    return nil unless response&.success?

    parse_response(response)
  end

  private

  def parse_response(response)
    {
      temperature: response["main"]["temp"],
      high: response["main"]["temp_max"],
      low: response["main"]["temp_min"],
      description: response["weather"].first["description"]
    }
  end
end
