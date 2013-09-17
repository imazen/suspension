module Suspension
  module Workflow
    class ConvertAtToPt

      attr_accessor :from_at, :tokens_to_remove

      # Converts from_at to pt, removing all at-specific tokens
      # @param[String] from_at the at_doc with at-specific tokens
      # @param[String] to_pt the pt_doc, without any at-specific tokens
      def self.run(from_at, tokens_to_remove = nil)
        new(from_at, tokens_to_remove).run
      end

      def initialize(from_at, tokens_to_remove = nil)
        @from_at = from_at
        @tokens_to_remove = tokens_to_remove || Suspension::AT_SPECIFIC_TOKENS
      end

      def run
        from = Suspender.new(from_at, tokens_to_remove).suspend
        from.filtered_text
      end

    end
  end
end
