class InstrumentsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception }, status: 404
  end

  #TODO error handling
  def index

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
      render json: {error: "Unprocessable entity"}, status: 422
    end
  end

  private
  def instrument_params
    _params = params.require(:instrument).permit(:Ticker, :CompanyName, :TimeCreated)
  end
end
