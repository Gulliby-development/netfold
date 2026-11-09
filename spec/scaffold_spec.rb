# frozen_string_literal: true

require "netfold"

RSpec.describe "scaffold" do
  it "loads the library" do
    expect(Netfold::VERSION).to eq("netfold 0.1.0")
  end
end
