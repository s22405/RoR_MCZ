class Instrument < ApplicationRecord
  has_many :Quotes, foreign_key: :Instrument_id

  validates :Ticker, presence: true, length: {minimum: 1, maximum: 5}
  validates :CompanyName, presence: false, length: {maximum: 200}
  validates :TimeCreated, presence: false
end
