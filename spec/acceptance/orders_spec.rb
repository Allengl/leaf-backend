require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  get "/api/v1/items" do
    example "Listing orders" do
      do_request

      expect(status).to eq 200
    end
  end
end
