module Suspension
  class SuspendedToken < Struct.new(:position, :name, :contents)
  end
end
