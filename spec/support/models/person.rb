require './spec/support/models/model'

class Person < Model

end

class Musician < Person

  def musician?
    true
  end
end
