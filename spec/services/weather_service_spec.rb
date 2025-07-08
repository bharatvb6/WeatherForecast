require 'rails_helper'

RSpec.describe WeatherService do
  let(:lat) { 37.4224764 }
  let(:lon) { -122.0842499 }
  let(:api_key) { ENV['WEATHER_API_KEY'] }
  let(:api_url) { "https://api.openweathermap.org/data/2.5/weather" }

  describe '.call' do
    context 'when the API returns a successful response' do
      before do
        stub_request(:get, api_url)
          .with(query: hash_including({
            lat: lat.to_s,
            lon: lon.to_s,
            appid: api_key,
            units: 'metric'
          }))
          .to_return(
            status: 200,
            body: {
              main: {
                temp: 25.3,
                temp_min: 21,
                temp_max: 28
              },
              weather: [
                { description: "clear sky" }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed forecast data' do
        result = described_class.call(lat, lon)
        expect(result).to eq({
          temperature: 25.3,
          high: 28,
          low: 21,
          description: "clear sky"
        })
      end
    end

    context 'when the API returns an error status' do
      before do
        stub_request(:get, api_url)
          .with(query: hash_including({
            lat: lat.to_s,
            lon: lon.to_s,
            appid: api_key,
            units: 'metric'
          }))
          .to_return(
            status: 404,
            body: {}.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns nil' do
        expect(described_class.call(lat, lon)).to be_nil
      end
    end

    context 'when the API call raises an exception' do
      before do
        stub_request(:get, api_url)
          .with(query: hash_including({
            lat: lat.to_s,
            lon: lon.to_s,
            appid: api_key,
            units: 'metric'
          }))
          .to_raise(StandardError.new("network error"))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with("[API ERROR] StandardError: network error")
        expect(described_class.call(lat, lon)).to be_nil
      end
    end
  end
end
