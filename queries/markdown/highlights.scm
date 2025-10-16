; Custom treesitter queries for markdown strikethrough support
; This extends the default markdown highlighting with strikethrough

; Strikethrough text (~~text~~)
((inline) @markup.strikethrough
  (#lua-match? @markup.strikethrough "~~[^~]+~~"))

; Strikethrough text in paragraphs
((paragraph (inline) @markup.strikethrough)
  (#lua-match? @markup.strikethrough "~~[^~]+~~"))

; Strikethrough text in list items
((list_item (paragraph (inline) @markup.strikethrough))
  (#lua-match? @markup.strikethrough "~~[^~]+~~"))