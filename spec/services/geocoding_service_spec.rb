require 'rails_helper'

RSpec.describe GeocodingService do
  describe '.call' do
    let(:address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
    let(:api_url) { "https://maps.googleapis.com/maps/api/geocode/json" }

    context "when the API returns a successful response" do
      before do
        stub_request(:get, api_url)
          .with(query: hash_including({
          	address: address,
          	key: ENV['GOOGLE_GEOCODING_API_KEY']
          }))
          .to_return(
            status: 200,
            body: {
					    "results": [
					        {
					            "address_components": [
					                {
					                    "long_name": "94043",
					                    "short_name": "94043",
					                    "types": [
					                        "postal_code"
					                    ]
					                }
					            ],
					            "formatted_address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
					            "geometry": {
					                "location": {
					                    "lat": 37.4222804,
					                    "lng": -122.0843428
					                },
					            }
					        }
					    ],
					    "status": "OK"
					}.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns the lat, lon, and zip" do
        result = described_class.call(address)
        expect(result).to eq({
          lat: 37.4222804,
          lon: -122.0843428,
          address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
          zip: "94043"
        })
      end
    end

    context "when the API returns an empty response" do
      before do
        stub_request(:get, api_url)
          .with(query: hash_including({
          	address: address,
          	key: ENV['GOOGLE_GEOCODING_API_KEY']
          }))
          .to_return(
            status: 200,
            body: {}.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns nil" do
        result = described_class.call(address)
        expect(result).to be_nil
      end
    end

    context "when the API request fails" do
      before do
        stub_request(:get, api_url)
          .with(query: hash_including({
          	address: address,
          	key: ENV['GOOGLE_GEOCODING_API_KEY']
          }))
          .to_raise(StandardError.new("network error"))
      end

      it "returns nil and logs the error" do
        expect(Rails.logger).to receive(:error).with("[API ERROR] StandardError: network error")
        result = described_class.call(address)
        expect(result).to be_nil
      end
    end
  end
end
