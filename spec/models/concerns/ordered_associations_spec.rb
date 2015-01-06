require 'rails_helper'

RSpec.describe OrderedAssociations do
  class Bowl
    include Mongoid::Document
    include OrderedAssociations
    embeds_many :fruits

    def names(sort_field = :position)
      fruits.sort_by(&sort_field).collect(&:name)
    end
  end

  class Fruit
    include Mongoid::Document
    field :name, type: String
    embedded_in :bowl
  end

  subject(:bowl) { Bowl.new(fruits: [apple, banana, coconut]) }
  let(:apple) { Fruit.new name: 'apple' }
  let(:banana) { Fruit.new name: 'banana' }
  let(:coconut) { Fruit.new name: 'coconut' }

  it 'defines ::keep_ordered' do
    expect(Bowl).to respond_to(:keep_ordered)
  end

  context 'with default configuration' do
    before do
      Bowl.keep_ordered :fruits
      Fruit.field :position, type: Integer

      apple.position = 1
      banana.position = 0
      coconut.position = 2
    end

    it 'orders the association' do
      bowl.valid?
      expect(bowl.names).to eq(%w(banana apple coconut))
    end

    it 'adds new elements last' do
      bowl.fruits.unshift Fruit.new(name: 'dragonfruit')
      bowl.valid?
      expect(bowl.names).to eq(%w(banana apple coconut dragonfruit))
    end
  end

  context 'with custom configuration' do
    before do
      Bowl.keep_ordered :fruits, by: :custom
      Fruit.field :custom, type: Integer

      apple.custom = 1
      banana.custom = 0
      coconut.custom = 2
    end

    it 'orders the association' do
      bowl.valid?
      expect(bowl.names(:custom)).to eq(%w(banana apple coconut))
    end
  end
end
