# suspension - cross-format merging through token suspension

This library enables the transfer of text changes from one file to another, while preserving unique tokens in the destination file.

These tokens must be context-free, which is generally quite an issue, but certain formats such as Markdown and Wiki can handle it OK.

## Components

* Suspender - Removes the given set of tokens from the file, storing them in an offsets table (lossless)
* Unsuspender - Joins a base file and an offsets table together to procude a single output file
* TextReplayer - Push changes from one file to another while preserving unique tokens in the desintation file
* RelativeSuspendedTokens - (De)serialize a tab-delimited syntax for the offsets
* TokenReplacer - Push token offsets from one file to another


## Command line utility (incomplete)

		suspend push text from-file to-file [-tokens]
		TextReplayer.new(from-text,to-text).replay

		suspend push [:subtitle_mark] from-file to-file
		TokenReplacer.new(from-text,to-text, Suspension.REPOSITEXT_TOKENS, Suspension.REPOSITEXT_TOKENS).replace([:subtitle_mark]) --> to_file

		suspend strip frome-file to-file [-tokens]
		Suspender.new(from-text,Suspension.REPOSITEXT_TOKENS).suspend.filtered_text

		suspend export from-file to-file [-tokens]
		Exports the token offset list. 

		Suspender.new(from-text,Suspension.REPOSITEXT_TOKENS).suspend.matched_tokens.to_relative.serialize

		suspend import offset-file text-file, to-file
		Merges the offset and text file 