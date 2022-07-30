class CreateInstruments < ActiveRecord::Migration[7.0]
  def change
    create_table :instruments do |t|
      t.string :Ticker
      t.string :CompanyName
      t.timestamp :TimeCreated

      t.timestamps
    end
  end
end
