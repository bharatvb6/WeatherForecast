require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
	describe 'GET #new' do
	  it 'renders the new template' do
	    get :new
	    expect(response).to render_template(:new)
	  end
	end

	describe 'POST #create' do
	  let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
	  let(:zip) { '94043' }
	  let(:geo_result) do
	    { lat: 37.42, lon: -122.08, address: '1600 Amphitheatre Parkway, Mountain View, CA', zip: zip }
	  end

	  context 'when geocoding is successful' do
	    before do
	      allow(GeocodingService).to receive(:call).with(address).and_return(geo_result)
	    end

	    it 'sets the signed cookie and redirects to show' do
	      post :create, params: { address: address }

	      expect(response).to redirect_to(forecast_path(zip))
	      cookie_data = JSON.parse(cookies.signed["geo_#{zip}"], symbolize_names: true)
	      expect(cookie_data).to include(
	        lat: geo_result[:lat],
	        lon: geo_result[:lon],
	        address: geo_result[:address]
	      )
	    end
	  end

	  context 'when geocoding fails' do
	    before do
	      allow(GeocodingService).to receive(:call).with(address).and_return(nil)
	    end

	    it 'sets flash alert and redirects to new' do
	      post :create, params: { address: address }

	      expect(flash[:alert]).to eq("Could not geocode address. Please try again.")
	      expect(response).to redirect_to(new_forecast_path)
	    end
	  end
	end


	describe 'GET #show' do
	  let(:zip) { '94043' }
	  let(:geo_cookie_key) { "geo_#{zip}" }
	  let(:geo_data) do
	    { lat: 37.42, lon: -122.08, address: 'Some address' }
	  end
	  let(:forecast_result) do
	    {
	      temperature: 25.3,
	      high: 28,
	      low: 21,
	      description: 'clear sky'
	    }
	  end
	  let(:cache_key) { "forecast_#{zip}" }

	  context 'when geo cookie is missing' do
	    it 'sets flash and redirects to new' do
	      get :show, params: { id: zip }
	      expect(flash[:alert]).to eq("We don't have coordinates for this ZIP code. Please enter the address again.")
	      expect(response).to redirect_to(new_forecast_path)
	    end
	  end

	  context 'when geo cookie is present and forecast is cached' do
	    before do
	      cookies.signed[geo_cookie_key] = geo_data.to_json
	      Rails.cache.write(cache_key, forecast_result)
	    end

	    it 'assigns @forecast from cache and marks from_cache true' do
	      get :show, params: { id: zip }

	      expect(assigns(:forecast)).to eq(forecast_result)
	      expect(assigns(:from_cache)).to be true
	      expect(response).to render_template(:show)
	    end
	  end

	  context 'when geo cookie is present and forecast is not cached' do
	    before do
	      cookies.signed[geo_cookie_key] = geo_data.to_json
	      Rails.cache.delete(cache_key)
	      allow(WeatherService).to receive(:call).with(geo_data[:lat], geo_data[:lon]).and_return(forecast_result)
	    end

	    it 'calls WeatherService, caches result, and assigns @forecast' do
	      expect(Rails.cache.exist?(cache_key)).to be false

	      get :show, params: { id: zip }

	      expect(assigns(:forecast)).to eq(forecast_result)
	      expect(assigns(:from_cache)).to be false
	      expect(Rails.cache.read(cache_key)).to eq(forecast_result)
	      expect(response).to render_template(:show)
	    end
	  end
	end
end