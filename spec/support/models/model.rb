require 'ostruct'

class Model < OpenStruct

  def save!
    @persisted = true
  end

  def persisted?
    !!@persisted
  end
end
