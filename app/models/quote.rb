class Quote < ApplicationRecord
  belongs_to :Instrument
  accepts_nested_attributes_for :Instrument

  validates :Price, presence: true
  validates :Timestamp, presence: true
  validates :Instrument_id, presence: true
end
