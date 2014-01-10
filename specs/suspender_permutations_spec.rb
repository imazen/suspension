require_relative 'helper'

# Build cartesian products of token test strings where we combine a test string
# for each token type with one for every other token type. We test each
# permutation with and without plain text interspersed (prefix, infix, suffix)

module Suspension

  describe Suspender do

    describe 'permutations' do

      PRINT_DEBUG_INFO = false

      TokenExample = Struct.new(:name, :example_expectation, :example_test_suffix, :must_be_start_of_line)

      # Conventions:
      # * include expected trailing spaces in the TOKEN_EXAMPLES and
      #   NOT in :prefix in Random.word. When asserting expectations, they will
      #   be stripped from the TOKEN_EXAMPLES.
      TOKEN_EXAMPLES = [
        [:ald, "\n{:ref-name: #myid .my-class}\n", '', true],
        [:emphasis, "*", ''],
        [:emphasis, "**", ''],
        [:extension_block, "\n{::comment}\nblock comment\n{:/comment}\n", '', true],
        [:extension_block, "\n{::options key=\"block options\" /}\n", '', true],
        [:extension_span, "{::comment}span comment{:/}", ' '],
        [:extension_span, "{::options key=\"span options\" /}", ' '],
        [:gap_mark, "%", ''],
        [:header_atx, "\n#", '', true],
        [:header_atx, "\n##", ' ', true],
        [:header_atx, "\n###", '', true],
        [:header_atx, "\n####", ' ', true],
        [:header_atx, "\n#####", '', true],
        [:header_atx, "\n######", ' ', true],
        [:header_id, " {#id}", ''],
        [:header_setext, "\n-----\n", '', true],
        [:header_setext, "\n==\n", '', true],
        [:horizontal_rule, "\n***\n", '', true],
        [:ial_block, "\n{: #block-ial}\n", '', true],
        [:ial_span, "{:.span-ial}", ' '],
        [:image, "![alt text](image.jpeg)", ' '],
        [:record, "\n^^^\n", '', true],
        [:subtitle_mark, "@", '']
      ].map { |e| TokenExample.new(*e) }

      describe "with plain text" do
        TOKEN_EXAMPLES.each do |t1|
          TOKEN_EXAMPLES.each do |t2|
            prefix = t1.must_be_start_of_line ? "\n" : Random.word(:suffix => ' ')
            infix = Random.word(:suffix => t2.must_be_start_of_line ? "\n" : ' ')
            suffix = Random.word
            test_string = [
              prefix,
              t1.example_expectation,
              t1.example_test_suffix,
              infix,
              t2.example_expectation,
              t2.example_test_suffix,
              suffix
            ].join
            t1_pos = prefix.length
            t2_pos = t1_pos + t1.example_test_suffix.length + infix.length

            it "suspends w/ plain text\n>>>>\n#{ test_string }\n>>>> correctly" do
              puts test_string.inspect  if PRINT_DEBUG_INFO
              s = Suspender.new(test_string, REPOSITEXT_TOKENS).suspend
              s.suspended_tokens.to_flat \
               .must_equal [t1_pos, t1.example_expectation, t2_pos, t2.example_expectation]
            end

          end
        end
      end

      describe "without plain text" do

        # Returns true if this permutation should be skipped
        def compute_expectation(t1, t1_pos, t2, t2_pos)
          # Handle some special permutations first
          case
          when '*' == t1.example_expectation && '**' == t2.example_expectation
            # '***' (without trailing newline) is parsed as double asterisk,
            # then single asterisk. Just a matter or precedence. If the string
            # had a trailing newline, it would be parsed as horizontal_rule.
            [t1_pos, "**", t2_pos, "*"]
          when '*' == t1.example_expectation && '*' == t2.example_expectation
            # '**' is parsed as a single emphasis token with two asterisks,
            # rather than two emphasis tokens with a single asterisk
            [t1_pos, "**"]
          else
            # default expectation
            [t1_pos, t1.example_expectation, t2_pos, t2.example_expectation]
          end
        end

        TOKEN_EXAMPLES.each do |t1|
          TOKEN_EXAMPLES.each do |t2|
            prefix = t1.must_be_start_of_line ? "\n" : ''
            infix = t2.must_be_start_of_line ? "need this to avoid newline consumption by t1\n" : ''
            test_string = [
              prefix,
              t1.example_expectation,
              infix,
              t2.example_expectation
            ].join
            t1_pos = prefix.length
            t2_pos = t1_pos + infix.length

            it "suspends w/o plain text\n>>>>\n#{ test_string }\n>>>> correctly" do
              puts test_string.inspect  if PRINT_DEBUG_INFO
              s = Suspender.new(test_string, REPOSITEXT_TOKENS).suspend
              s.suspended_tokens.to_flat \
               .must_equal compute_expectation(t1, t1_pos, t2, t2_pos)
            end

          end
        end
      end

      describe 'PLAIN_TEXT_TOKENS regex' do
        # The purpose of this spec is to make sure that the PLAIN_TEXT_TOKENS
        # regex will never match any at-specific or kramdown-subset tokens.
        # We put it here since this is the place where we have a complete set
        # of example token strings.
        PLAIN_TEXT_TOKENS.each do |plain_text_token|
          TOKEN_EXAMPLES.each do |token|
            test_string = token.example_expectation
            it "PLAIN_TEXT_TOKEN #{ plain_text_token.name } doesn't match '#{ test_string.inspect }'" do
              puts test_string.inspect  if PRINT_DEBUG_INFO
              StringScanner.new(test_string).scan(plain_text_token.regex).must_be_nil
            end
          end
        end
      end

    end
  end
end
