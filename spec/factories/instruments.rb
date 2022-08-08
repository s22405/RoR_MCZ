FactoryBot.define do
  factory :instrument do
    Ticker {'AAPL'}
    CompanyName {'Apple'}
    TimeCreated {2.years.ago}
  end
end
