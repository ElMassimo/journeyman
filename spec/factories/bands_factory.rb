Journeyman.define :band do |c|
  c.ignore :musicians

  c.build { |attrs| Band.create_from(attrs) }

  c.after_create do |band, attrs|
    attrs.delete(:musicians).each { |musician| band.add_musician(musician) }
  end

  # Default
  {
    name: 'Jethro Tull'
  }
end

Journeyman.define :artist, parent: :band do |c|

  c.find { |attrs| Band.find_by(attrs) }

  # Default
  {
    name: 'Santana'
  }
end
