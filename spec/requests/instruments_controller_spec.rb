require 'rails_helper'

RSpec.describe "/instruments", type: :request do
  describe "GET index" do
    it "returns no instruments on empty database" do
      get "/instruments"

      expect(response.body).to eq("[]")
      expect(response.status).to eq(200)
    end

    it "returns all instruments (1)" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save

      get "/instruments"
      expect(JSON.parse(response.body)).to eq([instrument1].as_json)
      expect(response.status).to eq(200)
    end

    it "returns all instruments (3)" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument2 = FactoryBot.build(:instrument, Ticker: "def")
      instrument3 = FactoryBot.build(:instrument, Ticker: "ghi")
      instrument1.save
      instrument2.save
      instrument3.save

      get "/instruments"
      expect(JSON.parse(response.body)).to eq([instrument1,instrument2,instrument3].as_json)
      expect(response.status).to eq(200)
    end

    it "returns instrument with given ticker" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument2 = FactoryBot.build(:instrument, Ticker: "def")
      instrument3 = FactoryBot.build(:instrument, Ticker: "ghi")
      instrument1.save
      instrument2.save
      instrument3.save

      get "/instruments?ticker=abc"
      expect(JSON.parse(response.body)).to eq([instrument1].as_json)
      expect(response.status).to eq(200)
    end

    it "returns instrument with given companyname" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc", CompanyName: "ABC")
      instrument2 = FactoryBot.build(:instrument, Ticker: "def", CompanyName: "DEF")
      instrument3 = FactoryBot.build(:instrument, Ticker: "ghi", CompanyName: "GHI")
      instrument1.save
      instrument2.save
      instrument3.save

      get "/instruments?companyname=ABC"
      expect(JSON.parse(response.body)).to eq([instrument1].as_json)
      expect(response.status).to eq(200)
    end

    it "returns limited number of instruments" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc", CompanyName: "ABC")
      instrument2 = FactoryBot.build(:instrument, Ticker: "def", CompanyName: "DEF")
      instrument3 = FactoryBot.build(:instrument, Ticker: "ghi", CompanyName: "GHI")
      instrument1.save
      instrument2.save
      instrument3.save

      get "/instruments?limit=2"
      expect(JSON.parse(response.body)).to eq([instrument1,instrument2].as_json)
      expect(response.status).to eq(200)
    end

    it "returns limited number of instruments with offset" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc", CompanyName: "ABC")
      instrument2 = FactoryBot.build(:instrument, Ticker: "def", CompanyName: "DEF")
      instrument3 = FactoryBot.build(:instrument, Ticker: "ghi", CompanyName: "GHI")
      instrument1.save
      instrument2.save
      instrument3.save

      get "/instruments?limit=2&offset=1"
      expect(JSON.parse(response.body)).to eq([instrument2,instrument3].as_json)
      expect(response.status).to eq(200)
    end
  end

  describe "GET index/id" do
    it "returns a 404NotFound error" do
      get "/instruments/1"

      # expect(response.body).to eq("[]")
      expect(response.status).to eq(404)
    end

    it "returns the instrument of id 1" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save
      get "/instruments/1"

      expect(JSON.parse(response.body)).to eq(instrument1.as_json)
      expect(response.status).to eq(200)
    end

    it "returns the instrument of id 2" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save
      instrument2 = FactoryBot.build(:instrument, Ticker: "def")
      instrument2.save
      get "/instruments/2"

      expect(JSON.parse(response.body)).to eq(instrument2.as_json)
      expect(response.status).to eq(200)
    end
  end

  describe "PUT index/id" do
    it "returns a 404 NotFound error" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save

      put '/instruments/25', params:
        { instrument: {
          Ticker: "abc",
          CompanyName: "Testing",
          TimeCreated: "2022-07-28 18:18:29.294"
        } }

      expect(response.status).to eq(404)
    end

    it "updates the instrument of id 1" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save
      instrument2 = FactoryBot.build(:instrument, Ticker: "ghi")
      instrument2.save

      put '/instruments/1', params:
        { instrument: {
          Ticker: "def",
          CompanyName: "Testing",
          TimeCreated: "2022-07-28 18:18:29.294"
        } }

      expect(Instrument.count).to eq(2)
      expect(Instrument.first.Ticker).to eq("def")
      expect(Instrument.second.Ticker).to eq("ghi")
    end

    it "returns a 422 UnprocessableEntity error" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save

      put '/instruments/1', params:
        { instrument: {
          Ticker: "sdfdsfsdfsdf",
          CompanyName: "Testing",
          TimeCreated: "2022-07-28 18:18:29.294"
        } }

      expect(response.status).to eq(422)
    end
  end

  describe "create" do
    it "posts an instrument" do
      post '/instruments', params:
        { instrument: {
          Ticker: "abc",
          CompanyName: "Testing",
          TimeCreated: "2022-07-28 18:18:29.294"
        } }

      expect(Instrument.count).to eq(1)
      expect(Instrument.first.Ticker).to eq("abc")
      expect(Instrument.first.CompanyName).to eq("Testing")
      expect(Instrument.first.TimeCreated).to eq("2022-07-28 18:18:29.294")
    end

    # a testament to me trying
    #
    # it "returns an instrument created by POST" do
    #   instrument1 = FactoryBot.build(:instrument)
    #   put instrument1.to_param
    #   post '/instruments', params: instrument1.to_param
    #
    #   expect(Instrument.count).to eq(1)
    #   # expect(response.status).to eq(200)
    # end

    it "returns Error 422 due to bad parameters" do
      post '/instruments', params:
        { instrument: {
          Ticker: "abc",
          CompanyName: "Testing",
          TimeCreated: "abc"
        } }
      expect(response.status).to eq(422)
    end

    it "returns Error 422 due to duplicate ticker" do
      instrument1 = FactoryBot.build(:instrument, Ticker: "abc")
      instrument1.save

      post '/instruments', params:
        { instrument: {
          Ticker: "abc",
          CompanyName: "Testing",
          TimeCreated: "2022-07-28 18:18:29.294"
        } }

      expect(response.body).to eq("{\"error\":\"There's already an instrument with the given ticker\"}")
      expect(response.status).to eq(422)
    end

    it "returns Error 422 due to missing parameters" do
      post '/instruments', params:
        { instrument: {
          CompanyName: "Testing",
          TimeCreated: "2022-07-28 18:18:29.294"
        } }
      expect(response.status).to eq(422)
    end
  end
end
