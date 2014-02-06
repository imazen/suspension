# suspension - cross-format merging through token suspension

This library enables the transfer of text changes from one document to another,
while preserving unique tokens in the destination document.

These tokens must be context-free, which is generally quite an issue, but certain
formats such as Markdown and Wiki can handle it OK.

## Components

* Suspender - Removes the given set of tokens from the document, storing them in an
  offsets table (lossless).
* Unsuspender - Joins a base document and an offsets table together to procude a
  single output document.
* TextReplayer - Push changes from one document to another while preserving unique
  tokens in the destination document.
* RelativeSuspendedTokens - (De)serialize a tab-delimited syntax for the offsets.
* TokenReplacer - Push token offsets from one document to another.
* TokenRemover - Remove tokens from a document.

## How to run specs

Run entire spec suite:

    rake

or just run a single spec file:

    ruby specs/repositext_tokens_spec.rb


## Command line utility (incomplete)

		suspend push text from-file to-file [-tokens]
		TextReplayer.new(from-text, to-text).replay

		suspend push [:subtitle_mark] from-file to-file
		TokenReplacer.new(from-text,to-text, Suspension::REPOSITEXT_TOKENS, Suspension::REPOSITEXT_TOKENS).replace([:subtitle_mark]) --> to_file

		suspend strip frome-file to-file [-tokens]
		Suspender.new(from-text,Suspension::REPOSITEXT_TOKENS).suspend.filtered_text

		suspend export from-file to-file [-tokens]
		Exports the token offset list.

		Suspender.new(from-text,Suspension::REPOSITEXT_TOKENS).suspend.suspended_tokens.to_relative.serialize

		suspend import offset-file text-file, to-file
		Merges the offset and text file

## Diagrams

### Repositext tokens overview

[![Repositext tokens](https://raw.github.com/imazen/suspension/master/doc/images/rt_tokens.png)](https://raw.github.com/imazen/suspension/master/doc/images/rt_tokens.png)

### Workflow: Sync text changes from PT to AT

Retaining repositext tokens in AT.

[![Repositext tokens](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_sync_text_changes_from_pt_to_at.png)](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_sync_text_changes_from_pt_to_at.png)

### Workflow: Sync subtitle_marks from ST to AT

Retaining plain text and other repositext tokens in AT.

[![Repositext tokens](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_sync_subtitle_marks_from_st_to_at.png)](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_sync_subtitle_marks_from_st_to_at.png)

### Workflow: Convert AT to PT

Retaining kramdown-subset tokens, discarding at-specific tokens.

[![Repositext tokens](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_convert_at_to_pt.png)](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_convert_at_to_pt.png)

### Workflow: Sync record_mark tokens from AT V2 to AT V1

Retaining all other tokens in AT V1.

[![Repositext tokens](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_sync_record_tokens_from_at_to_at.png)](https://raw.github.com/imazen/suspension/master/doc/images/rt_wf_sync_record_tokens_from_at_to_at.png)
