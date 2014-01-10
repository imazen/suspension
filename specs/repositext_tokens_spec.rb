require_relative 'helper'

module Suspension

  describe 'REPOSITEXT_TOKENS regex parsing' do

    # Helper to test token regexes. Asserts that REPOSITEXT_TOKEN with
    # token_name will consume test_string in its entirety.
    # @param[Symbol] token_name the name of the token under test
    # @param[String] test_string the test string
    def token_must_parse_string(token_name, test_string)
      token = get_token(token_name)
      raise(InvalidTokenNameError, "Invalid token_name: #{ token_name.inspect }") unless token
      StringScanner.new(test_string).scan(token.regex).must_equal(test_string)
    end

    # Returns the repositext token with token_name
    # @param[Symbol] token_name
    # @return[Token]
    def get_token(token_name)
      REPOSITEXT_TOKENS.detect { |e| token_name == e.name }
    end

    # ******************************************
    # at-specific tokens
    # ******************************************

    describe "gap_mark" do
      it "parses simple %" do
        token_must_parse_string(:gap_mark, "%")
      end
    end

    describe "subtitle_mark" do
      it "parses simple @" do
        token_must_parse_string(:subtitle_mark, "@")
      end
    end

    describe "record (with and without preceding blank line)" do
      [
        "\n^^^\n",
        "\n^^^ {:.rid}\n",
        "\n^^^\n{:.rid}\n",
        "\n^^^  {:.rid #rid-123abc}\n",
        "^^^\n",
        "^^^ {:.rid}\n",
        "^^^\n{:.rid}\n",
        "^^^  {:.rid #rid-123abc}\n",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:record, test_string)
        end
      end
    end

    # ******************************************
    # kramdown-subset tokens
    # ******************************************

    describe "ald" do
      [
        "\n{:ref-name: #myid .my-class}\n",
        "{:ref-name: #myid .my-class}\n",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:ald, test_string)
        end
      end
    end

    describe "emphasis" do
      ["*", "**", "_", "__"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:emphasis, test_string)
        end
      end
    end

    describe "extension_block" do
      [
        "\n{::comment}\nBlock comment extension\n{:/comment}\n",
        "\n{::comment} Span comment extension {:/comment}\n",
        "\n{::options key=\"val\" /}\n",
        "\n{::nomarkdown}This *is* not processed{:/nomarkdown}\n",
        "{::comment}\nBlock comment extension\n{:/comment}\n",
        "{::comment} Span comment extension {:/comment}\n",
        "{::options key=\"val\" /}\n",
        "{::nomarkdown}This *is* not processed{:/nomarkdown}\n",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:extension_block, test_string)
        end
      end
    end

    describe "extension_span" do
      [
        "{::comment}\nBlock comment extension\n{:/comment}",
        "{::comment} Span comment extension {:/comment}",
        "{::options key=\"val\" /}",
        "{::nomarkdown}This *is* not processed{:/nomarkdown}"
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:extension_span, test_string)
        end
      end
    end

    describe "header_atx" do
      [
        "\n#", "\n##", "\n###", "\n####", "\n#####", "\n######",
        "#", "##", "###", "####", "#####", "######",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:header_atx, test_string)
        end
      end
    end

    describe "header_id" do
      [' {#id}'].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:header_id, test_string)
        end
      end
    end

    describe "header_setext" do
      [
        "\n-\n", "\n------------\n", "\n=\n", "\n===\n",
        "-\n", "------------\n", "=\n", "===\n",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:header_setext, test_string)
        end
      end
    end

    describe "horizontal_rule" do
      [
        "\n***\n", "\n   ***\n", "\n* * *\n", "\n---\n", "\n___\n",
        "***\n", "   ***\n", "* * *\n", "---\n", "___\n",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:horizontal_rule, test_string)
        end
      end
    end

    describe "ial_block" do
      [
        "\n{: #ial}\n", "\n{:.rid}\n",
        "{: #ial}\n", "{:.rid}\n",
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:ial_block, test_string)
        end
      end
    end

    describe "ial_span" do
      ["{: #ial}", "{:.rid}"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:ial_span, test_string)
        end
      end
    end

    describe "image" do
      [
        "![alt text](/images/other.png)",
        "![alt text](/images/other.png \"title\")",
        "![alt text]()"
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:image, test_string)
        end
      end
    end

  end

end
