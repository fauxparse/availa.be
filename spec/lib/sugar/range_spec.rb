require 'rails_helper'

RSpec.describe Range do
  describe "#range" do
    it "gives the range of values contained" do
      expect((0..10).range).to eq(10)
    end
  end
end
