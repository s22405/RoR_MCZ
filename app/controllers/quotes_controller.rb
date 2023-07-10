class QuotesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception }, status: 404
  end

  private def build_quote
    ticker = params[:Ticker]
    instrument = Instrument.find_by_Ticker(ticker)
    if instrument.nil?
      instrument = Instrument.new(Ticker: ticker)
      unless instrument.save
        render json: { error: "Unprocessable entity" }, status: 422
      end
    end
    instrument.quotes.build(quote_params)
  end

  #TODO error handling
  def index

    quotes = Quote.all

    if params[:ticker]
      quotes = quotes.where(instrument: Instrument.where(Ticker: params[:ticker]))
    end
    if params[:companyname]
      quotes = quotes.where(instrument: Instrument.where(CompanyName: params[:companyname]))
    end
    if params[:offset]
      quotes = quotes.offset(params[:offset])
    end
    if params[:limit]
      quotes = quotes.limit(params[:limit])
    end

    render json: quote_presenter(quotes)
  end

  def show
    quote = Quote.find(params[:id])
    render json: quote_presenter(quote)
  end

  def create
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.transaction(isolation: :repeatable_read) do
      quote = build_quote

      if quote.save
        render json: quote_presenter(quote)
      else
        render json: {error: "Unprocessable entity"}, status: 422
      end
    end
  end

  private
  def quote_params
    params.permit(:Timestamp, :Price)
  end

  def quote_presenter(quote)
    quote.as_json(only: [:id, :Timestamp, :Price, :created_at, :updated_at ], include: :instrument)
  end
end