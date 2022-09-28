class AddIndexToTicker < ActiveRecord::Migration[7.0]
  def change
    add_index :instruments, :Ticker, unique: true
  end
end
