require_relative 'helper'

module Suspension

  describe SuspendedToken do

    %w[
      contents
      name
      position
    ].each do |accessor_name|
      it "has '#{ accessor_name }' accessor" do
        @suspended_token = SuspendedToken.new(nil, nil, nil)
        @suspended_token.send("#{ accessor_name }=", accessor_name)
        @suspended_token.send(accessor_name).must_equal accessor_name
      end
    end

  end

end
