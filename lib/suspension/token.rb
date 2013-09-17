module Suspension
  class Token < Struct.new(:name, :regex, :must_be_at_start_of_line, :is_plaintext)
  end
end
