require 'spec_helper'
require './spec/support/models/person'
require './spec/support/models/artist'
require './spec/support/models/album'

describe 'simple' do

  context '#find default' do
    Given do
      allow(Musician).to receive(:find_by).and_return { |attrs| Musician.new(attrs) }
    end
    When(:person) { find_musician('Jimi Hendrix') }
    Then { person.name == 'Jimi Hendrix' }
  end

  context '#find by name' do
    Given do
      allow(Person).to receive(:find_by).and_return { |attrs| Person.new(attrs) }
    end
    When(:person) { find_person('John Doe') }
    Then { person.name == 'John Doe' }
  end

  context '#find by email' do
    Given do
      allow(Person).to receive(:find_by).and_return { |attrs| Person.new(attrs) }
    end
    When(:person) { find_person('johndoe@nobody.com') }
    Then { person.email == 'johndoe@nobody.com' }
  end

  context '#find with alternate attribute' do
    Given do
      allow(Album).to receive(:find_by).and_return { |attrs| Album.new(attrs) }
    end
    When(:album) { find_album('Wish you Were Here') }
    Then { album.title == 'Wish you Were Here' }
  end

  context '#find with custom finder' do
    Given do
      allow(Band).to receive(:find_by).and_return { |attrs| Artist.new(name: 'B.B. King', genre: 'Blues') }
    end
    When(:artist) { find_artist('B.B. King') }
    Then { artist.name == 'B.B. King' }
    And  { artist.genre == 'Blues' }
  end
end
