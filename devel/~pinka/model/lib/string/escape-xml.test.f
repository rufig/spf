REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`match.f.xml EMBODY

`escape-xml.f.xml EMBODY

  ' TYPE 
  S" 'AT&T'. 1<2 & 2<3 & 3<4 & 4<5  <[[-<>-]]>" ESCAPE-XML-PER-
  CR
  ' TYPE
  S" 1&lt;2 &amp; 2&lt;3 &amp; 3&lt;4 &amp; 4&lt;5  &lt;[[-&lt;>-]]&gt;" UNESCAPE-XML-PER-
  CR
