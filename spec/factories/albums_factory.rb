require './spec/support/models/album'

Journeyman.define :album, finder_attribute: :title do |c|
  {
    title: 'Wish You Were Here'
  }
end

Journeyman.define :generic_album, model: Album do
end
