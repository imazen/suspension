require_relative 'helper'

module Suspension

  describe TokenReplacer do

    it "replaces a single token_name" do
      TokenReplacer.new(
        "aabbc@cnn@",
        "aab@bccnn%",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replace([:a]).must_equal "aabbc@cnn%@"
    end

    it "replaces multiple token names" do
      TokenReplacer.new(
        "aabbc@cnn@",
        "aab@bccnn%",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replace([:a, :b]).must_equal "aabbc@cnn@"
    end

    it "replaces multiple token names" do
      TokenReplacer.new(
        "@a %longer string with @a %larger number of @tokens %that vary quite @a %bit.",
        "!a #long%er !string #wi%th !a #larger !nu@mb#er o#f !tok@ens th%at va@ry quit%e a@ bi%#!t.",
        [Token.new(:a, /@/), Token.new(:b, /%/), Token.new(:c, /!/), Token.new(:d, /#/)]
      ).replace([:a, :b]).must_equal "!@a #%longer !string #with !@a #%larger !numb#er o#f !@tokens %that vary quite @a %bi#!t."
    end

  end

end
