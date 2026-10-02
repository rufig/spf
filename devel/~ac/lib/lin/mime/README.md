# MIME header API

The existing `ParseMessageText`, `ParseMessageFile`, multipart parser and header
structures remain available. `mime.f` retains its original CP1251 encoding.

`ParseMessageHeaders ( addr len -- part )` is a bounded header-only entry point.
It reuses `ParseHeaderLine`, `EnumMimeHeaders`, `FindMimeHeader`, `/MimeHeader`
and `/MimePart`. It does not parse content parameters, multipart bodies or nested
messages. The input is borrowed, not modified; keep it alive while using the part.
`mpHeaderAddr/Len` includes the empty separator line; `mpBodyAddr/Len` identifies
the untouched remaining bytes. `mpParts` and content-type metadata remain zero.

`FreeMimeHeaders ( part -- )` releases the returned part and its header nodes,
not the input. It is **not** a destructor for a multipart tree from
`ParseMessageText`. Zero is accepted. Header lookup returns slices of the
original buffer; folded values retain their original CRLF/LF and whitespace.
Callers decide whether/how to unfold values. Enumerate headers when duplicate
fields must be rejected; `FindMimeHeader` returns only the first match.

Limits: 64 KiB through the separator, 998 bytes per physical header line excluding
CRLF/LF, 2048 fields. Missing separators, orphan continuations, invalid field
names and control bytes other than HTAB fail with `MIME-INVALID-HEADERS` (-12120).
Limit violations fail with `MIME-HEADERS-LIMIT` (-12121). The body is opaque and
may contain arbitrary binary bytes. CRLF and LF may be read independently of LTL.

The entry point restores `MimePart` and `CurrentHeader` on success and failure;
allocated header nodes are freed before propagating an error. Parsing uses
`EVALUATE-WITH` with the explicit line parser, never the default text interpreter.
The caller must separately bound total message size and authorize access.

Compatibility fixes also applied to the legacy parser:

- Parameter aliases use ordinary search order, not the caller's `::` handler.
- New header/part structures are explicitly zeroed.
- Continuation lengths use positions in the source, not the output line ending LTL.

Run `spf64 devel/~ac/lib/lin/mime/headers-test.f` from the SPF root. Tests cover
CRLF/LF, folded values, unchanged body ranges, error cleanup, allocator failures,
balanced allocations across repeated calls, and the legacy plain-message API.
Tested on Windows x64 and Linux x64; other platforms were not run in this change.
