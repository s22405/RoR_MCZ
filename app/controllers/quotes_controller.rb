class QuotesController < ApplicationController
  def index
    params.permit(:ticker, :companyname) #TODO companyname worked even without permitting it?

    quotes = Quote.all

    if params[:ticker]
      quotes = quotes.where(Instrument: Instrument.where(Ticker: params[:ticker]))
    end
    if params[:companyname]
      quotes = quotes.where(Instrument: Instrument.where(CompanyName: params[:companyname]))
    end

    render json: quote_presenter(quotes)
  end

  def show
    quote = Quote.find(params[:id])
    render json: quote_presenter(quote)
  end

  private
  def quote_presenter(quote)
    quote.as_json(only: [:id, :Timestamp, :Price, :created_at, :updated_at ],include: :Instrument)
  end
end


