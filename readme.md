# Sugar2TeXML
XSLT converting .tex.xml file to [TeXML](http://getfo.org/texml) and some TeX files needed to compile.
In addition, [BibTeXML](http://bibtexml.sourceforge.net) may be needed. 

## component
```mermaid
graph TB
	Document-->|sugar2texml|TeXML
	TeXML-->|LaTeXML|LaTeX
	LaTeX-->|LuaLaTeX|PDF
	Document-->|sugar2html|XHTML
	XHTML-->|Reveal.js|S5
	Document-->|sugar2md|MarkDown
	Document-->|sugar2gb|GitBook
```
