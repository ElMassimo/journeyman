def name_or_email(id)
  id =~ /@/ ? :email : :name
end

def process_name(attrs)
  if (first_name = attrs.delete(:first_name)) && (last_name = attrs.delete(:last_name))
    attrs[:name] = "#{first_name} #{last_name}"
  end
  attrs
end

Journeyman.define :person do |c|
  c.find { |id|
    Person.find_by(name_or_email(id) => id)
  }
  c.process { |attrs| process_name(attrs) }
  {
    name: 'John Doe',
    email: 'johndoe@nobody.com',
    password: 'feelthemusic',
    job: 'unemployed'
  }
end

Journeyman.define(:musician, parent: :person) do |c|
  {
    name: 'Jimi Hendrix',
    email: 'jimi@hendrix.com',
    job: :musician,
    albums: -> {
      ['Are You Experienced?', 'Axxis: Bold as Love', 'Electric Ladyland'].map { |title|
        Journeyman.create(:album, title: title)
      }
    }
  }
end
