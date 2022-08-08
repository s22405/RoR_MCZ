require 'rails_helper'

RSpec.describe "application", type: :request do
  describe "Page not found" do
    it "returns Error 404 on non-existing page" do
      get "/intrament"

      expect(response.status).to eq(404)
    end
  end
end
