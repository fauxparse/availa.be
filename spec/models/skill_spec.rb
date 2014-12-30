require 'rails_helper'

RSpec.describe Skill, :type => :model do
  subject(:skill) { FactoryGirl.create :skill }

  describe "#plural" do
    context "when explicitly set" do
      before do
        skill.update plural: "plural"
      end

      it "returns the custom value" do
        expect(skill.plural).to eq("plural")
      end
    end

    context "when not explicitly set" do
      it "returns the default value" do
        expect(skill.plural).to eq(skill.name.pluralize)
      end
    end
  end
end
