class CreateQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :quotes do |t|
      t.timestamp :Timestamp
      t.decimal :Price
      t.references :Instrument, null: false, foreign_key: true

      t.timestamps
    end
  end
end
