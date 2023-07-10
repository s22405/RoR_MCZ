FactoryBot.define do
  factory :quote do
    Timestamp {2.years.ago}
    Price {100.2}
    instrument_id {1}
  end
end
