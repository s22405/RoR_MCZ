class Instrument < ApplicationRecord
  has_many :quotes, foreign_key: :instrument_id

  validates :Ticker, presence: true, length: {minimum: 1, maximum: 5}
  validates :CompanyName, presence: false, length: {maximum: 200}
  validates :TimeCreated, presence: false
end
