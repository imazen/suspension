module Suspension
  class Token < Struct.new(:name, :regex, :must_be_start_of_line, :is_plaintext, :is_transparent_to_beginning_of_line)
  end
end
