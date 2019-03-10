<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings" xmlns="http://getfo.sourceforge.net/texml/ns1" extension-element-prefixes="str">
 <xsl:template name="br-replace">
  <xsl:param name="word"/>
  <xsl:choose>
   <xsl:when test="contains($word,'\\')">
    <xsl:value-of select="substring-before($word,'\\')"/>
    <ctrl ch="\"/>
    <xsl:call-template name="br-replace">
     <xsl:with-param name="word" select="substring-after($word,'\\')"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise><xsl:value-of select="$word"/></xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="log">
  <!-- 本文中の数式などをそのままTeX構文として利用 -->
  <TeXML escape="0">
   <!-- config -->
   <cmd name="newcommand" nl2="1"><parm><cmd name="Option" gr="0"/></parm><parm><xsl:value-of select="@option"/></parm></cmd>
   <cmd name="newcommand" nl2="1">
    <parm><cmd name="Author" gr="0"/></parm>
    <parm><xsl:call-template name="br-replace"><xsl:with-param name="word" select="@by"/></xsl:call-template></parm>
   </cmd>
   <cmd name="newcommand" nl2="1">
    <parm><cmd name="Title" gr="0"/></parm>
    <parm><xsl:call-template name="br-replace"><xsl:with-param name="word" select="@title"/></xsl:call-template></parm>
   </cmd>

   <!-- include headers -->
   <cmd name="include" nl2="1"><parm>
   <xsl:choose>
    <xsl:when test="@slide">myslide</xsl:when>
    <xsl:when test="@plan">myplan</xsl:when>
    <xsl:otherwise>myarticle</xsl:otherwise>
   </xsl:choose>
   </parm></cmd>
   <xsl:if test="@embed"><cmd name="include" nl2="1"><parm>embed</parm></cmd></xsl:if>

   <!-- bibliography -->
   <xsl:if test="@biball"><cmd name="nocite"><parm>*</parm></cmd></xsl:if>
   <xsl:if test="@bib"><cmd name="bibliography" nl2="1"><parm><xsl:value-of select="@bib"/></parm></cmd></xsl:if>
   <cmd gr="0" nl2="1"><xsl:attribute name="name">Header<xsl:if test="@cover">Page</xsl:if></xsl:attribute></cmd>
   <xsl:if test="@plan"><env name="flushright" nl4="1">授業者: <xsl:value-of select="@by"/></env></xsl:if>
   <xsl:apply-templates/>
   <xsl:if test="@bib">
    <xsl:choose>
     <xsl:when test="@slide">
      <cmd name="renewcommand*" nl2="1"><parm><cmd name="bibfont" gr="0"/></parm><parm><cmd name="scriptsize" gr="0"/></parm></cmd>
      <env name="frame" nl4="1"><opt>allowframebreaks</opt>
       <cmd name="frametitle"><parm>Reference</parm></cmd>
       <cmd name="printbibliography" nl2="1" gr="0"/>
      </env>
     </xsl:when>
     <xsl:otherwise><cmd name="printbibliography" nl2="1" gr="0"/></xsl:otherwise>
    </xsl:choose>
   </xsl:if>
   <!--</env>-->
   <TeXML escape="0">\end{document}</TeXML>
  </TeXML>
 </xsl:template>

 <!-- native elements of TeXML -->
 <xsl:template match="cmd | opt | parm">
  <xsl:element name="{name()}">
   <xsl:if test="@name"><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute></xsl:if>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>

 <xsl:template match="m">
  <env nl2="1" nl4="1">
   <xsl:attribute name="name">align<xsl:if test="not(@n)">*</xsl:if></xsl:attribute>
   <xsl:apply-templates/>
   <xsl:if test="@n"><cmd name="label"><parm><xsl:value-of select="@n"/></parm></cmd></xsl:if>
  </env>
  </xsl:template>

 <!-- heading -->
 <xsl:template name="heading">
  <xsl:param name="level"/>
  <cmd gr="0" nl1="1" nl2="1">
   <xsl:attribute name="name"><xsl:value-of select="$level"/><xsl:text>section</xsl:text><xsl:if test="@no=0">*</xsl:if></xsl:attribute>
   <parm><xsl:value-of select="@h"/><xsl:if test="@n"><cmd name="label"><parm><xsl:value-of select="@n"/></parm></cmd></xsl:if></parm>
  </cmd>
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="article/s | article/multicols/s | appendix/s">
  <xsl:call-template name="heading"/>
 </xsl:template>

 <xsl:template match="article/s/s | article/multicols/s/s | appendix/s/s">
  <xsl:call-template name="heading">
   <xsl:with-param name="level">sub</xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <xsl:template match="article/s/s/s | article/multicols/s/s/s | appendix/s/s/s">
  <xsl:call-template name="heading">
   <xsl:with-param name="level">subsub</xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <xsl:template match="appendix">
  <cmd name="appendix" gr="0" nl2="1"/>
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="aside">
  <env name="tcolorbox" nl4="1"><opt>breakable,title=Info: <xsl:value-of select="@h"/></opt><xsl:apply-templates/></env>
 </xsl:template>

 <!-- layout -->
 <xsl:template match="hr"><cmd name="newpage" gr="0" nl2="1"/></xsl:template>

 <xsl:template match="multicols">
  <xsl:choose>
   <xsl:when test="@flex">
    <env name="multicols" nl4="1"><parm><xsl:value-of select="count(*)"/></parm><xsl:apply-templates/></env>
   </xsl:when>
   <xsl:when test="@num">
    <env name="multicols" nl4="1"><parm><xsl:value-of select="@num"/></parm><xsl:apply-templates/></env>
   </xsl:when>
   <xsl:otherwise>
    <env name="columns" nl4="1"><xsl:apply-templates/></env>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 <xsl:template match="column">
  <env name="column" nl2="1" nl4="1"><parm><xsl:value-of select="@width"/></parm><xsl:apply-templates/></env>
 </xsl:template>

 <!-- code/sample -->
 <xsl:template match="code">
  <xsl:choose>
   <xsl:when test="@class"><cmd name="lstset" nl2="1"><parm>language=<xsl:value-of select="@class"/></parm></cmd></xsl:when>
   <xsl:when test="@src"  ><cmd name="lstset" nl2="1"><parm>language=<xsl:value-of select="str:tokenize(@src, '.')[last()]"/></parm></cmd></xsl:when>
  </xsl:choose>
  <xsl:choose>
   <xsl:when test="@src"><cmd name="lstinputlisting" nl2="1"><parm><xsl:value-of select="@src"/></parm></cmd></xsl:when>
   <xsl:otherwise><env name="lstlisting" nl4="1"><xsl:apply-templates/></env></xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="samp"><env name="alltt" nl4="1"><xsl:apply-templates/></env></xsl:template>

 <!-- text decoration -->
 <xsl:template match="p">
  <cmd name="par" gr="0"/>
  <xsl:if test="/log/@slide"><cmd name="quad" gr="0"/></xsl:if>
  <xsl:apply-templates/>
 </xsl:template>
 <xsl:template match="br"><ctrl ch="\"/></xsl:template>

 <xsl:template match="em"  ><cmd name="em"  ><parm><xsl:apply-templates/></parm></cmd></xsl:template>
 <xsl:template match="fn"  ><cmd name="fn"  ><parm><xsl:apply-templates/></parm></cmd></xsl:template>
 <xsl:template match="ruby"><cmd name="ruby"><parm><xsl:apply-templates/></parm><parm><xsl:value-of select="@r"/></parm></cmd></xsl:template>
 <xsl:template match="u"><cmd name="underline"><parm><xsl:apply-templates/></parm></cmd></xsl:template>
 <xsl:template match="c"><cmd name="textcolor"><parm><xsl:value-of select="@fg"/></parm><parm><xsl:apply-templates/></parm></cmd></xsl:template>
 <xsl:template match="size">
  <group>
   <cmd gr="0"><xsl:attribute name="name"><xsl:value-of select="@size"/></xsl:attribute></cmd>
   <xsl:apply-templates/>
  </group>
 </xsl:template>

 <xsl:template match="a">
  <xsl:apply-templates/>
  <xsl:if test="node()"> (</xsl:if>
  <xsl:choose>
   <xsl:when test="starts-with(@href,'doi:')">
    <cmd name="href">
     <parm>http://doi.org/<xsl:value-of select="substring-after(@href,':')"/></parm>
     <parm><xsl:value-of select="@href"/></parm>
    </cmd>
   </xsl:when>
   <xsl:otherwise>
    <cmd name="url">
     <parm><xsl:value-of select="@href"/></parm>
    </cmd>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="node()">)</xsl:if>
 </xsl:template>

 <!-- list -->
 <xsl:template match="dl | ol | ul">
  <env nl4="1">
   <xsl:attribute name="name">
    <xsl:choose>
     <xsl:when test="@class='cases'">casesproof</xsl:when>
     <xsl:when test="name()='dl'">description</xsl:when>
     <xsl:when test="name()='ul'">itemize</xsl:when>
     <xsl:otherwise>enumerate</xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>
   <xsl:apply-templates/>
  </env>
 </xsl:template>

 <xsl:template match="li">
  <cmd name="item" gr="0" nl1="1">
   <xsl:if test="@mark"><opt><xsl:value-of select="@mark"/></opt></xsl:if>
  </cmd>
  <xsl:apply-templates/>
  </xsl:template>
 <xsl:template match="dt">
  <cmd name="item" gr="0"><opt><xsl:apply-templates/></opt></cmd> <cmd name="quad" gr="0"/><ctrl ch="\"/>
 </xsl:template>

 <xsl:template match="dd"><xsl:apply-templates/></xsl:template>

 <!-- cite -->
 <xsl:template match="l"   ><cmd name="label"><parm><xsl:value-of select="@n"/></parm></cmd></xsl:template>
 <xsl:template match="r"   ><cmd name="ref"  ><parm><xsl:value-of select="@n"/></parm></cmd></xsl:template>
 <xsl:template match="cite"><cmd name="cite" ><parm><xsl:value-of select="@id"/></parm></cmd></xsl:template>
 <xsl:template match="blockquote"><env name="quotation" nl4="1"><xsl:apply-templates/></env></xsl:template>
 <xsl:template match="q">
  <xsl:text>「</xsl:text><xsl:apply-templates /><xsl:text>」</xsl:text>
 </xsl:template>

 <!-- tabular -->
 <xsl:template match="hl"><cmd name="hline" gr="0"/></xsl:template>
 <xsl:template match="ss"><cmd name="shortstack"><parm><xsl:apply-templates/></parm></cmd></xsl:template>

 <xsl:template match="tabular">
  <!-- begin env -->
  <TeXML escape="0">
  <xsl:choose>
   <xsl:when test="@wrapwidth">\begin{wraptable}{r}{<xsl:value-of select="@wrapwidth"/>}</xsl:when>
   <xsl:when test="@long">\begin{longtable}{<xsl:value-of select="@align"/>}</xsl:when>
   <xsl:when test="@title">\begin{table}[hbtp]</xsl:when>
  </xsl:choose>
  </TeXML>
<!--  <env nl2="1" nl4="1">
  <xsl:choose>
   <xsl:when test="@wrapwidth">
    <xsl:attribute name="name">wraptable</xsl:attribute>
    <parm>r</parm><parm><xsl:value-of select="@wrapwidth"/></parm>
   </xsl:when>
   <xsl:when test="@long">
    <xsl:attribute name="name">longtable</xsl:attribute>
    <parm><xsl:value-of select="@align"/></parm>
   </xsl:when>
   <xsl:when test="@title">
    <xsl:attribute name="name">table</xsl:attribute>
    <opt>hbtp</opt>
   </xsl:when>
  </xsl:choose>-->
  <group><cmd name="centering" gr="0"/>
  <!-- settings -->
  <cmd name="rowcolors" nl2="1"><parm>1</parm><parm/><parm>lightpurple</parm></cmd>
  <!-- tabular -->
  <xsl:choose>
   <xsl:when test="@long"><xsl:apply-templates/></xsl:when>
   <xsl:otherwise>
    <group>
     <xsl:if test="@size"><cmd gr="0"><xsl:attribute name="name"><xsl:value-of select="@size"/></xsl:attribute></cmd></xsl:if>
     <xsl:choose>
      <xsl:when test="@src">
       <!-- 標準のcsvsimpleでは、先頭行がなぜか表示されない。
       \csvreader[tabular=<xsl:value-of select="@align"/>]{<xsl:value-of select="@src"/>}{}{\csvlinetotablerow}&#10;
       -->
       <cmd name="csvloop"><parm>bautotabular={<xsl:value-of select="@src"/>}{<xsl:value-of select="@align"/>}</parm></cmd>
      </xsl:when>
      <xsl:otherwise>
       <env name="tabular" nl2="1" nl4="1"><parm><xsl:value-of select="@align"/></parm><xsl:apply-templates/></env>
      </xsl:otherwise>
     </xsl:choose>
    </group>
   </xsl:otherwise>
  </xsl:choose>
  <!-- caption/label -->
  <!-- longtableではcaptionを上に移すとエラーになる -->
  <xsl:if test="@title"><cmd name="caption"><parm><xsl:value-of select="@title"/></parm></cmd></xsl:if>
  <xsl:if test="@n"><cmd name="label"><parm><xsl:value-of select="@n"/></parm></cmd></xsl:if>
  </group>
  <!-- end env -->
  <!--  </env>-->
  <TeXML escape="0">
  <xsl:choose>
   <xsl:when test="@wrapwidth">\end{wraptable}</xsl:when>
   <xsl:when test="@long">\end{longtable}</xsl:when>
   <xsl:when test="@title">\end{table}</xsl:when>
  </xsl:choose>
  </TeXML>
 </xsl:template>

 <!-- graphic -->
 <xsl:template match="img">
  <env nl2="1" nl4="1">
  <xsl:choose>
   <xsl:when test="@wrapwidth">
    <xsl:attribute name="name">wrapfigure</xsl:attribute>
    <parm>r</parm><parm><xsl:value-of select="@wrapwidth"/></parm>
   </xsl:when>
   <xsl:when test="@multicols">
    <xsl:attribute name="name">figurehere</xsl:attribute>
   </xsl:when>
   <xsl:otherwise>
    <xsl:attribute name="name">figure</xsl:attribute>
    <opt>hbtp</opt>
   </xsl:otherwise>
  </xsl:choose>
  <group><cmd name="centering" gr="0"/>
   <!-- includegraphics -->
   <cmd name="includegraphics">
    <xsl:if test="@scale"><opt>scale=<xsl:value-of select="@scale"/></opt></xsl:if>
    <parm>
     <xsl:value-of select="substring-before(@src,'.')"/>
     <xsl:choose>
      <xsl:when test="contains(@src,'.svg')"><xsl:text>.pdf</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>.</xsl:text><xsl:value-of select="substring-after(@src,'.')"/></xsl:otherwise>
     </xsl:choose>
    </parm>
   </cmd>
   <!-- caption/label -->
   <xsl:if test="@title"><cmd name="caption"><parm><xsl:value-of select="@title"/></parm></cmd></xsl:if>
   <xsl:if test="@n"><cmd name="label"><parm><xsl:value-of select="@n"/></parm></cmd></xsl:if>
  </group>
  </env>
 </xsl:template>

 <!-- Beamer -->
 <xsl:template match="frame">
  <env name="frame" nl4="1">
   <xsl:if test="@allowframebreaks"><opt>allowframebreaks</opt></xsl:if>
   <cmd name="frametitle" nl2="1"><parm><xsl:value-of select="@title"/></parm></cmd>
   <xsl:apply-templates/>
  </env>
 </xsl:template>
 <xsl:template match="block">
  <env nl2="1" nl4="1">
   <xsl:attribute name="name"><xsl:value-of select="@class"/>block</xsl:attribute>
   <parm><xsl:value-of select="@title"/></parm>
   <xsl:apply-templates/>
  </env>
 </xsl:template>
 <xsl:template match="alert | strong"><cmd name="alert"><parm><xsl:apply-templates/></parm></cmd></xsl:template>
 <xsl:template match="dfn">
  <xsl:variable name="env">
   <xsl:choose>
    <xsl:when test="@strong=0">em</xsl:when>
    <xsl:otherwise>alert</xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <cmd>
   <xsl:attribute name="name"><xsl:value-of select="$env"/></xsl:attribute>
   <parm><xsl:apply-templates/></parm>
  </cmd>
  <xsl:if test="@abbr">
   <xsl:text>(</xsl:text>
   <cmd>
    <xsl:attribute name="name"><xsl:value-of select="$env"/></xsl:attribute>
    <parm><xsl:value-of select="@abbr"/></parm>
   </cmd>
   <xsl:text>)</xsl:text>
  </xsl:if>
  <xsl:if test="@en">
   <xsl:text>(</xsl:text>
   <cmd>
    <xsl:attribute name="name"><xsl:value-of select="$env"/></xsl:attribute>
    <parm><xsl:value-of select="@en"/></parm>
   </cmd>
   <xsl:text>)</xsl:text>
  </xsl:if>
 </xsl:template>

 <!-- plan -->
 <xsl:template match="plantable">
  <env name="longtable"><parm>|p{30px}|p{350px}|p{100px}|</parm> <cmd name="hline" gr="0"/>
   展開 &amp; $\circ$:指導課程, $\bullet$:学習活動, 枠内:板書 &amp; 留意事項 <ctrl ch="\"/><cmd name="hline" gr="0"/>
   <xsl:apply-templates/>
   <cmd name="hline" gr="0"/>
  </env>
 </xsl:template>

 <xsl:template match="sect">
  <cmd name="hline" gr="0" nl1="1"/>
  <xsl:if test="@name">
   <cmd name="shortstack"><parm><xsl:value-of select="@name"/> <ctrl ch="\"/>(<xsl:value-of select="@min"/>分)</parm></cmd>
  </xsl:if> &amp; <cmd name="mainbox"><parm><cmd name="widc" gr="0"/></parm><parm>
  <xsl:for-each select="s | t | bb">
   <xsl:choose>
    <xsl:when test="name() = 's'">$\bullet$</xsl:when>
    <xsl:when test="name() = 't'"><group><cmd name="Large" gr="0"/> $\circ$</group></xsl:when>
   </xsl:choose>
   <xsl:if test="name() = 'bb'"><TeXML escape="0">\bb{</TeXML></xsl:if>
   <xsl:apply-templates/>
   <xsl:if test="name() = 'bb'"><TeXML escape="0">}</TeXML></xsl:if>
   <xsl:if test="position() != last()"><ctrl ch="\"/></xsl:if>
   <xsl:text>&#10;</xsl:text>
  </xsl:for-each>
  </parm></cmd> &amp; <cmd name="mainbox"><parm><cmd name="widn" gr="0"/></parm><parm>
  <xsl:apply-templates select="note"/>
  </parm></cmd>
  <ctrl ch="\"/>
 </xsl:template>

</xsl:stylesheet>
