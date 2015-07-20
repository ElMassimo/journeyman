require 'spec_helper'
require './spec/support/models/person'
require './spec/support/models/artist'
require './spec/support/models/album'

describe '#create' do

  context 'when the factory can be found' do
    # object is invariably persisted because we're using #create
    Invariant { object.persisted? }

    context 'simple' do
      When(:object) { Journeyman.create(:person) }
      Then { object.name == 'John Doe' }
    end

    context 'with a parent' do
      When(:object) { Journeyman.create(:musician) }
      Then { object.name == 'Jimi Hendrix' }
      And  { object.password == 'feelthemusic' }
      And  { object.albums.map(&:title) == ['Are You Experienced?', 'Axxis: Bold as Love', 'Electric Ladyland'] }
      And  { object.albums.all?(&:persisted?) }
    end

    context 'with a custom builder' do
      Given(:musicians) { [double(:musician), double(:musician)] }
      Given do
        expect(Band).to receive(:create_from).and_return { |attrs| Band.new(attrs) }
        expect_any_instance_of(Band).to receive(:add_musician).twice
      end
      When(:object) { Journeyman.create(:band, name: 'Deep Purple', musicians: musicians) }
      Then { object.name == 'Deep Purple' }
      And  { object.musicians.nil? }
    end

    context 'with a processor' do
      When(:object) { Journeyman.create(:person, first_name: 'Eddie', last_name: 'Vedder') }
      Then { object.name == 'Eddie Vedder' }
      And  { object.first_name.nil? }
      And  { object.last_name.nil? }
    end
  end

  context 'when the factory does not exist' do
    When(:object) { Journeyman.create(:some_foolishness) }
    Then { expect(object).to have_failed(Journeyman::MissingFactoryError) }
  end
end

describe 'dynamically generated helper methods' do
  context 'simple' do
    When(:object) { create_person }
    Then { object.name == 'John Doe' }
  end

  context 'with attributes' do
    When(:object) { create_person(first_name: 'Jane', last_name: 'Doe') }
    Then { object.name == 'Jane Doe' }
  end
end
