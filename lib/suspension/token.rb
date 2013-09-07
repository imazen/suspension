module Suspension
  class Token < Struct.new(:name, :regex, :is_plaintext)
  end
end
