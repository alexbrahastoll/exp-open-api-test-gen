class CitiesController < ApplicationController
  def show
    render json: find_city_by_name(params[:name])
  end

  private

  def find_city_by_name(name)
    name = name.downcase.gsub(/\s+/, ' ')
    cities = {
      'la paz' => {
        altitude: 3640, # in meters
        pressure: 0.6604 # in atm (considering a temperature of 15 degrees celsius)
      },
      'mexico city' => {
        altitude: 2240,
        pressure: 0.7717
      },
      'copenhagen' => {
        altitude: 0,
        pressure: 1
      }
    }
    altitude_and_pressure = cities[name]
    altitude_and_pressure ||= cities['la paz']
  end
end
