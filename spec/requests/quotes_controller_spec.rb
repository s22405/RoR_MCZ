require 'rails_helper'

RSpec.describe "/quotes", type: :request do
  before do
    instrument1 = FactoryBot.build(:instrument, Ticker: "abc", CompanyName: "ABC")
    instrument2 = FactoryBot.build(:instrument, Ticker: "def", CompanyName: "DEF")
    instrument3 = FactoryBot.build(:instrument, Ticker: "ghi", CompanyName: "GHI")
    instrument1.save
    instrument2.save
    instrument3.save
  end

  describe "GET index" do

    it "returns no quotes on empty database" do
      get "/quotes"

      expect(response.body).to eq("[]")
      expect(response.status).to eq(200)
    end

    it "returns all quotes (1)" do
      quote1 = FactoryBot.build(:quote)
      quote1.save

      get "/quotes"
      expect(JSON.parse(response.body)[0]["Instrument"]["Ticker"]).to eq("abc")
      expect(JSON.parse(response.body)[0]["Price"]).to eq("100.2")
      expect(response.status).to eq(200)
    end

    it "returns all quotes (3)" do
      quote1 = FactoryBot.build(:quote)
      quote2 = FactoryBot.build(:quote, Instrument_id: "2", Price: "100.3")
      quote3 = FactoryBot.build(:quote, Instrument_id: "3", Price: "100.4")
      quote1.save
      quote2.save
      quote3.save

      get "/quotes"
      expect(JSON.parse(response.body)[0]["Instrument"]["Ticker"]).to eq("abc")
      expect(JSON.parse(response.body)[0]["Price"]).to eq("100.2")
      expect(JSON.parse(response.body)[1]["Instrument"]["Ticker"]).to eq("def")
      expect(JSON.parse(response.body)[1]["Price"]).to eq("100.3")
      expect(JSON.parse(response.body)[2]["Instrument"]["Ticker"]).to eq("ghi")
      expect(JSON.parse(response.body)[2]["Price"]).to eq("100.4")
      expect(response.status).to eq(200)
    end

    it "returns quote with given ticker" do
      quote1 = FactoryBot.build(:quote, Instrument_id: 1)
      quote2 = FactoryBot.build(:quote, Instrument_id: 2)
      quote3 = FactoryBot.build(:quote, Instrument_id: 3)
      quote1.save
      quote2.save
      quote3.save

      get "/quotes?ticker=abc"
      expect(JSON.parse(response.body)[0]["Instrument"]["Ticker"]).to eq("abc")
      expect(response.status).to eq(200)
    end

    it "returns quote with given companyname" do
      quote1 = FactoryBot.build(:quote, Instrument_id: 1)
      quote2 = FactoryBot.build(:quote, Instrument_id: 2)
      quote3 = FactoryBot.build(:quote, Instrument_id: 3)
      quote1.save
      quote2.save
      quote3.save

      get "/quotes?companyname=ABC"
      expect(JSON.parse(response.body)[0]["Instrument"]["CompanyName"]).to eq("ABC")
      expect(response.status).to eq(200)
    end

    it "returns limited number of quotes" do
      quote1 = FactoryBot.build(:quote, Instrument_id: 1)
      quote2 = FactoryBot.build(:quote, Instrument_id: 2)
      quote3 = FactoryBot.build(:quote, Instrument_id: 3)
      quote1.save
      quote2.save
      quote3.save

      get "/quotes?limit=2"
      expect(JSON.parse(response.body)[0]["Instrument"]["Ticker"]).to eq("abc")
      expect(JSON.parse(response.body)[1]["Instrument"]["Ticker"]).to eq("def")
      expect(response.status).to eq(200)
    end

    it "returns limited number of quotes with offset" do
      quote1 = FactoryBot.build(:quote, Instrument_id: 1)
      quote2 = FactoryBot.build(:quote, Instrument_id: 2)
      quote3 = FactoryBot.build(:quote, Instrument_id: 3)
      quote1.save
      quote2.save
      quote3.save

      get "/quotes?limit=2&offset=1"
      expect(JSON.parse(response.body)[0]["Instrument"]["Ticker"]).to eq("def")
      expect(JSON.parse(response.body)[1]["Instrument"]["Ticker"]).to eq("ghi")
      expect(response.status).to eq(200)
    end
  end

  describe "GET index/id" do

    it "returns a 404 NotFound error" do
      get "/quotes/1"

      expect(response.status).to eq(404)
    end

    it "returns the quote of id 1" do
      quote1 = FactoryBot.build(:quote)
      quote1.save
      get "/quotes/1"

      expect(JSON.parse(response.body)["Instrument"]["Ticker"]).to eq("abc")
      expect(JSON.parse(response.body)["Price"]).to eq("100.2")
      expect(response.status).to eq(200)
    end

    it "returns the instrument of id 2" do
      quote1 = FactoryBot.build(:quote)
      quote2 = FactoryBot.build(:quote, Instrument_id: "2", Price: "100.3")
      quote1.save
      quote2.save
      get "/quotes/2"

      expect(JSON.parse(response.body)["Instrument"]["Ticker"]).to eq("def")
      expect(JSON.parse(response.body)["Price"]).to eq("100.3")
      expect(response.status).to eq(200)
    end
  end

  describe "create" do

    it "posts a quote" do
      post '/quotes', params:
        {
          Ticker: "abc",
          Price: "100.2",
          Timestamp: "2022-07-28 18:18:29.294"
        }

      expect(Quote.count).to eq(1)
      expect(Quote.first.Price).to eq(100.2)
    end

    it "returns Error 422 due to bad parameters" do
      post '/quotes', params:
        {
          Ticker: "abc",
          Price: "100.2",
          Timestamp: "abc"
        }
      expect(response.status).to eq(422)
    end

    it "returns Error 404 due to non-existing ticker" do
      post '/quotes', params:
        {
          Ticker: "dogma",
          Price: "100.2",
          Timestamp: "2022-07-28 18:18:29.294"
        }

      expect(response.status).to eq(404)
    end

    it "returns Error 422 due to missing parameters" do
      post '/quotes', params:
        {
          Ticker: "abc",
          Price: "100.2",
        }

        expect(response.status).to eq(422)
    end
  end
end
