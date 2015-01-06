require 'rails_helper'

RSpec.describe Event::Role, type: :model do
  subject(:role) { event.roles.build skill: skill }
  let(:group) { FactoryGirl.create :group }
  let(:event) { FactoryGirl.create :event, group: group }
  let(:skill) { FactoryGirl.create :skill, group: group }

  [:dumbledore, :harry, :hermione, :ron].each do |user|
    let(user) { FactoryGirl.create user }
  end

  describe '#plural' do
    context 'without a name set' do
      it 'uses the plural from the skill' do
        expect(role.plural).to eq(role.skill.plural)
      end
    end

    context 'with a name set' do
      before { role.name = 'beater' }

      it 'pluralizes the custom name' do
        expect(role.plural).to eq('beaters')
      end
    end

    context 'with a plural set' do
      before do
        role.name = 'beater'
        role.plural = 'phat beaters'
      end

      it 'uses the custom plural' do
        expect(role.plural).to eq('phat beaters')
      end
    end
  end

  describe '#optional?' do
    context 'without a minimum' do
      it { is_expected.to be_optional }
    end

    context 'with a minimum' do
      before do
        role.minimum = 1
      end

      it { is_expected.not_to be_optional }
    end
  end

  describe '#unlimited?' do
    context 'without a maximum' do
      it { is_expected.to be_unlimited }
      it { is_expected.not_to be_full }
    end

    context 'with a maximum' do
      before do
        role.maximum = 1
      end

      it { is_expected.not_to be_unlimited }
      it { is_expected.not_to be_full }
    end
  end

  describe '#name' do
    context 'without a name' do
      it 'uses the name of the associated skill' do
        expect(role.name).to eq(role.skill.name)
      end
    end

    context 'with a name' do
      before do
        role.name = 'fish'
      end

      it 'uses its own name' do
        expect(role.name).to eq('fish')
      end
    end
  end

  describe '#assignments' do
    before do
      role.minimum = 1
      role.maximum = 2
    end

    context 'with no assigned users' do
      it { is_expected.to be_valid }
      it { is_expected.not_to be_satisfied }
      it { is_expected.not_to be_full }
    end

    context 'with one assigned user' do
      before do
        assign harry
      end

      it { is_expected.to be_valid }
      it { is_expected.to be_satisfied }
      it { is_expected.not_to be_full }
    end

    context 'with two assigned users' do
      before do
        assign harry, hermione
      end

      it { is_expected.to be_valid }
      it { is_expected.to be_satisfied }
      it { is_expected.to be_full }
    end

    context 'with three assigned users' do
      before do
        assign harry, hermione, ron
      end

      it { is_expected.not_to be_valid }
      it { is_expected.to be_satisfied }
      it { is_expected.to be_full }
    end
  end

  def assign(*users)
    users.each do |user|
      role.assignments << Event::Assignment.new(user: user)
    end
  end
end
