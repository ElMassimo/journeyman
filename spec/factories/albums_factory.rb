require './spec/support/models/album'

Journeyman.define :album, finder_attribute: :title do |c|
  {
    title: 'Wish You Were Here'
  }
end

Journeyman.define :no_default, model: Album do |c|
end
