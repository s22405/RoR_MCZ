class Quote < ApplicationRecord
  belongs_to :instrument
  # accepts_nested_attributes_for :Instrument

  validates :Price, presence: true
  validates :Timestamp, presence: true
  validates :instrument_id, presence: true
end
