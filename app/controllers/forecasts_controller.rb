class ForecastsController < ApplicationController
  def new
  end

  def create
    address = params[:address]
    geo_result = GeocodingService.call(address)

    if geo_result.nil? || geo_result[:zip].blank?
      flash[:alert] = "Could not geocode address. Please try again."
      redirect_to new_forecast_path
      return
    end

    cookies.signed["geo_#{geo_result[:zip]}"] = {
      value: { lat: geo_result[:lat], lon: geo_result[:lon], address: geo_result[:address]  }.to_json,
      expires: 30.days.from_now
    }

    redirect_to forecast_path(geo_result[:zip])
  end

  def show
    zip = params[:id]
    geo_data_json = cookies.signed["geo_#{params[:id]}"]

    if geo_data_json
      @geo = JSON.parse(geo_data_json, symbolize_names: true)
    else
      flash[:alert] = "We don't have coordinates for this ZIP code. Please enter the address again."
      redirect_to new_forecast_path and return
    end

    cache_key = "forecast_#{zip}"
    @from_cache = Rails.cache.exist?(cache_key)
    @forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      WeatherService.call(@geo[:lat], @geo[:lon])
    end
  end
end
