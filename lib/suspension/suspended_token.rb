module Suspension

  # @param[Integer] position
  # @param[Symbol] name
  # @param[String] contents
  class SuspendedToken < Struct.new(:position, :name, :contents)
  end

end
