require 'spec_helper'
require './spec/support/models/person'
require './spec/support/models/artist'
require './spec/support/models/album'

describe '#build' do
  describe 'when the factory exists' do
    # object is invariably not persisted because #build only instantiates
    Invariant { !object.persisted? }

    context 'when the factory does not have default attributes' do
      When(:object) { Journeyman.build(:generic_album) }
      Then { object.is_a?(Album) }
    end

    context 'when the factory has default attributes' do
      When(:object) { Journeyman.build(:person) }
      Then { object.is_a?(Person) }
      Then { object.name == 'John Doe' }
    end

    context 'when the factory has a parent' do
      When(:object) { Journeyman.build(:musician) }
      Then { object.is_a?(Person) }
      And { object.name == 'Jimi Hendrix' }
      And  { object.password == 'feelthemusic' }
      And  { object.albums.map(&:title) == ['Are You Experienced?', 'Axxis: Bold as Love', 'Electric Ladyland'] }
      # FIXME: seems kind of awkward that we are only building the musician, but persisting his albums
      # is that expected? @ElMassimo
      And  { object.albums.all?(&:persisted?) }
    end

    context 'when using a custom builder' do
      Given do
        expect(Band).to receive(:create_from).and_return { |attrs| Band.new(attrs) }
      end
      When(:object) { Journeyman.build(:band, name: 'Deep Purple') }
      Then { object.name == 'Deep Purple' }
      And  { object.musicians.nil? }
    end

    context '#build with processor' do
      When(:object) { Journeyman.build(:person, first_name: 'Eddie', last_name: 'Vedder') }
      Then { object.name == 'Eddie Vedder' }
      And  { object.first_name.nil? }
      And  { object.last_name.nil? }
    end
  end

  context 'when the factory does not exist' do
    When(:object) { Journeyman.build(:some_nonsense) }
    Then { expect(object).to have_failed(Journeyman::MissingFactoryError) }
  end
end
