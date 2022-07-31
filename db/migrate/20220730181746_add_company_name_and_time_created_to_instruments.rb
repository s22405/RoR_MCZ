class AddCompanyNameAndTimeCreatedToInstruments < ActiveRecord::Migration[7.0]
  def change
    add_column :instruments, :CompanyName, :string
    add_column :instruments, :TimeCreated, :timestamp
  end
end
