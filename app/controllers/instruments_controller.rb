class InstrumentsController < ApplicationController
  def index
    params.permit(:ticker, :companyname) #TODO companyname worked even without permitting it?

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

  # def new
  #   Instrument.new
  # end

  # def create
  #   Instrument.new(instrument_params)
  #
  #   if @article.save
  #     redirect_to @article
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  private
  def instrument_params
    params.require(:instrument).permit(:Ticker, :CompanyName, :TimeCreated)
  end
end
