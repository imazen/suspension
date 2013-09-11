require_relative 'helper'

module Suspension

  describe Token do

    %w[
      is_plaintext
      name
      regex
    ].each do |accessor_name|
      it "has '#{ accessor_name }' accessor" do
        @token = Token.new(nil, nil, nil)
        @token.send("#{ accessor_name }=", accessor_name)
        @token.send(accessor_name).must_equal accessor_name
      end
    end

  end

end
