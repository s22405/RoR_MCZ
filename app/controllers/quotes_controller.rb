class QuotesController < ApplicationController
  def index
    # params= #TODO errors with this
      params.permit(:ticker, :companyname)

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

  def create
    quote = build_quote

    if quote.save
      render json: quote
    else
      render status: :unprocessable_entity
    end
  end

  private
  def build_quote
    #TODO Transaction
    instrument = Instrument.find_by_Ticker(params[:Ticker])
    if instrument.present?
      instrument.Quotes.build(quote_params)
    end
  end

  private

  def quote_params
    params.permit(:Timestamp, :Price)
  end

  def quote_presenter(quote)
    quote.as_json(only: [:id, :Timestamp, :Price, :created_at, :updated_at ],include: :Instrument)
  end
end


