class Quote < ApplicationRecord
  belongs_to :Instrument

  validates :Price, presence: true
  validates :Timestamp, presence: true
  validates :Instrument_id, presence: true
end
