require_relative 'helper'

module Suspension

  describe 'REPOSITEXT_TOKENS' do

    # Helper to test token regexes
    # @param[Symbol] token_name the name of the token under test
    # @param[String] test_string the test string
    # @return[String] the matched token
    def token_must_parse_string(token_name, test_string)
      token = get_token(token_name)
      raise(ArgumentError, "Invalid token_name: #{ token_name.inspect }") unless token
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

    describe "record" do
      it "parses simple record" do
        token_must_parse_string(:record, "^^^\n")
      end
    end

    # ******************************************
    # kramdown-subset tokens
    # ******************************************

    describe "ald" do
      ["{:ref-name: #myid .my-class}\n"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:ald, test_string)
        end
      end
    end

    describe "atx_header" do
      ["#", "##", "###", "####", "#####", "######"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:atx_header, test_string)
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

    describe "extension" do
      [
        "{::comment}\nBlock comment extension\n{:/comment}",
        "{::comment} Span comment extension {:/comment}",
        "{::options key=\"val\" /}",
        "{::nomarkdown}This *is* not processed{:/nomarkdown}"
      ].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:extension, test_string)
        end
      end
    end

    describe "header id" do
      ['{#id}'].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:header_id, test_string)
        end
      end
    end

    describe "horizontal_rule" do
      ["***\n", "   ***\n", "* * *\n", "---\n", "___\n"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:horizontal_rule, test_string)
        end
      end
    end

    describe "ial" do
      ["{: #ial}"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:ial, test_string)
        end
      end
    end

    describe "setext_header" do
      ["-\n", "------------\n", "=\n", "===\n"].each do |test_string|
        it "parses '#{ test_string.inspect }'" do
          token_must_parse_string(:setext_header, test_string)
        end
      end
    end

  end

end
