class Instrument < ApplicationRecord
  has_many :Quotes, foreign_key: :Instrument_id

  validates :Ticker, presence: true, length: {minimum: 1, maximum: 5}
  validates :CompanyName, presence: true, length: {minimum: 1, maximum: 200}
  validates :TimeCreated, presence: true
end
