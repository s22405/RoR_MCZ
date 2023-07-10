class InstrumentsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception }, status: 404
  end

  rescue_from ActiveRecord::RecordNotUnique do |exception|
    render json: { error: "There's already an instrument with the given ticker" }, status: 422
    # TODO double check the status code
    # potential candidates
    # 400 - bad request
    # 409 - conflict
    # 417 - expectation failed
  end

  def index

    instruments = Instrument.all

    if params[:ticker]
      instruments = instruments.where(Ticker: params[:ticker])
    end
    if params[:companyname]
      instruments = instruments.where(CompanyName: params[:companyname])
    end
    if params[:offset]
      instruments = instruments.offset(params[:offset])
    end
    if params[:limit]
      instruments = instruments.limit(params[:limit])
    end

    render json: instruments
  end

  def show
    render json: Instrument.find(params[:id])
  end

  def create
    #not going to break in case of 2 instances with the same ticker
    instrument = Instrument.new(instrument_params)
    if instrument.save
      render json: instrument
    else
      render json: {error: "Unprocessable entity"}, status: 422
    end
  end

  def update
    #not going to break in case of 2 instances
    instrument = Instrument.find(params[:id])

    if instrument.update(instrument_params)
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
