require 'spec_helper'
require './spec/support/models/person'
require './spec/support/models/artist'
require './spec/support/models/album'

describe 'simple' do

  Invariant { !object.persisted? }

  context '#build without_defaults' do
    When(:object) { Journeyman.build(:no_default) }
    Then { object.is_a?(Album) }
  end

  context '#build default' do
    When(:object) { Journeyman.build(:person) }
    Then { object.name == 'John Doe' }
  end

  context '#build parent' do
    When(:object) { Journeyman.build(:musician) }
    Then { object.name == 'Jimi Hendrix' }
    And  { object.password == 'feelthemusic' }
    And  { object.albums.map(&:title) == ['Are You Experienced?', 'Axxis: Bold as Love', 'Electric Ladyland'] }
    And  { object.albums.all?(&:persisted?) }
  end

  context '#build with custom builder' do
    Given do
      expect(Band).to receive(:create_from).and_return { |attrs| Band.new(attrs) }
    end
    When(:object) { build_band(name: 'Deep Purple') }
    Then { object.name == 'Deep Purple' }
    And  { object.musicians.nil? }
  end

  context '#build with processor' do
    When(:object) { build_person(first_name: 'Eddie', last_name: 'Vedder') }
    Then { object.name == 'Eddie Vedder' }
    And  { object.first_name.nil? }
    And  { object.last_name.nil? }
  end
end
