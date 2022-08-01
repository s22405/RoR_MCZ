class InstrumentsController < ApplicationController
  def index
    # params= #TODO errors with this
      params.permit(:ticker, :companyname)

    instruments = Instrument.all

    if params[:ticker]
      instruments = instruments.where(Ticker: params[:ticker])
    end
    if params[:companyname]
      instruments = instruments.where(CompanyName: params[:companyname])
    end

    render json: instruments
  end

  def show
    render json: Instrument.find(params[:id])
  end

  def create
    instrument = Instrument.new(instrument_params)

    if instrument.save
      render json: instrument
    else
      render status: :unprocessable_entity
    end
  end

  private
  def instrument_params #TODO also check if this works
    _params = params.require(:instrument).permit(:Ticker, :CompanyName, :TimeCreated)
    if Instrument.find_by_Ticker(_params[:Ticker]).present?
      0 #TODO replace this with something better
    else
      _params
    end
  end
end
