#
#
#            Nim's Runtime Library
#        (c) Copyright 2012 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements an AST for the `reStructuredText`:idx: parser.

import strutils, json

type
  TRstNodeKind* = enum        ## the possible node kinds of an PRstNode
    rnInner,                  # an inner node or a root
    rnHeadline,               # a headline
    rnOverline,               # an over- and underlined headline
    rnTransition,             # a transition (the ------------- <hr> thingie)
    rnParagraph,              # a paragraph
    rnBulletList,             # a bullet list
    rnBulletItem,             # a bullet item
    rnEnumList,               # an enumerated list
    rnEnumItem,               # an enumerated item
    rnDefList,                # a definition list
    rnDefItem,                # an item of a definition list consisting of ...
    rnDefName,                # ... a name part ...
    rnDefBody,                # ... and a body part ...
    rnFieldList,              # a field list
    rnField,                  # a field item
    rnFieldName,              # consisting of a field name ...
    rnFieldBody,              # ... and a field body
    rnOptionList, rnOptionListItem, rnOptionGroup, rnOption, rnOptionString, 
    rnOptionArgument, rnDescription, rnLiteralBlock, rnQuotedLiteralBlock,
    rnLineBlock,              # the | thingie
    rnLineBlockItem,          # sons of the | thing
    rnBlockQuote,             # text just indented
    rnTable, rnGridTable, rnTableRow, rnTableHeaderCell, rnTableDataCell,
    rnLabel,                  # used for footnotes and other things
    rnFootnote,               # a footnote
    rnCitation,               # similar to footnote
    rnStandaloneHyperlink, rnHyperlink, rnRef, rnDirective, # a directive
    rnDirArg, rnRaw, rnTitle, rnContents, rnImage, rnFigure, rnCodeBlock,
    rnRawHtml, rnRawLatex,
    rnContainer,              # ``container`` directive
    rnIndex,                  # index directve:
                              # .. index::
                              #   key
                              #     * `file#id <file#id>`_
                              #     * `file#id <file#id>'_
    rnSubstitutionDef,        # a definition of a substitution
    rnGeneralRole,            # Inline markup:
    rnSub, rnSup, rnIdx, 
    rnEmphasis,               # "*"
    rnStrongEmphasis,         # "**"
    rnTripleEmphasis,         # "***"
    rnInterpretedText,        # "`"
    rnInlineLiteral,          # "``"
    rnSubstitutionReferences, # "|"
    rnSmiley,                 # some smiley
    rnLeaf                    # a leaf; the node's text field contains the
                              # leaf val


  PRstNode* = ref TRstNode    ## an RST node
  TRstNodeSeq* = seq[PRstNode]
  TRstNode* {.acyclic, final.} = object ## an RST node's description
    kind*: TRstNodeKind       ## the node's kind
    text*: string             ## valid for leafs in the AST; and the title of
                              ## the document or the section
    level*: int               ## valid for some node kinds
    sons*: TRstNodeSeq        ## the node's sons

proc len*(n: PRstNode): int = 
  result = len(n.sons)

proc newRstNode*(kind: TRstNodeKind): PRstNode = 
  new(result)
  result.sons = @[]
  result.kind = kind

proc newRstNode*(kind: TRstNodeKind, s: string): PRstNode = 
  result = newRstNode(kind)
  result.text = s

proc lastSon*(n: PRstNode): PRstNode = 
  result = n.sons[len(n.sons)-1]

proc add*(father, son: PRstNode) =
  add(father.sons, son)

proc addIfNotNil*(father, son: PRstNode) = 
  if son != nil: add(father, son)


type
  TRenderContext {.pure.} = object
    indent: int
    verbatim: int

proc renderRstToRst(d: var TRenderContext, n: PRstNode, result: var string)

proc renderRstSons(d: var TRenderContext, n: PRstNode, result: var string) = 
  for i in countup(0, len(n) - 1): 
    renderRstToRst(d, n.sons[i], result)
  
proc renderRstToRst(d: var TRenderContext, n: PRstNode, result: var string) =
  # this is needed for the index generation; it may also be useful for
  # debugging, but most code is already debugged...
  const 
    lvlToChar: array[0..8, char] = ['!', '=', '-', '~', '`', '<', '*', '|', '+']
  if n == nil: return
  var ind = repeatChar(d.indent)
  case n.kind
  of rnInner: 
    renderRstSons(d, n, result)
  of rnHeadline:
    result.add("\n")
    result.add(ind)
    
    let oldLen = result.len
    renderRstSons(d, n, result)
    let headlineLen = result.len - oldLen

    result.add("\n")
    result.add(ind)
    result.add repeatChar(headlineLen, lvlToChar[n.level])
  of rnOverline:
    result.add("\n")
    result.add(ind)

    var headline = ""
    renderRstSons(d, n, headline)
    
    let lvl = repeatChar(headline.len - d.indent, lvlToChar[n.level])
    result.add(lvl)
    result.add("\n")
    result.add(headline)
    
    result.add("\n")
    result.add(ind)
    result.add(lvl)
  of rnTransition: 
    result.add("\n\n")
    result.add(ind)
    result.add repeatChar(78-d.indent, '-')
    result.add("\n\n")
  of rnParagraph:
    result.add("\n\n")
    result.add(ind)
    renderRstSons(d, n, result)
  of rnBulletItem: 
    inc(d.indent, 2)
    var tmp = ""
    renderRstSons(d, n, tmp)
    if tmp.len > 0: 
      result.add("\n")
      result.add(ind)
      result.add("* ")
      result.add(tmp)
    dec(d.indent, 2)
  of rnEnumItem:
    inc(d.indent, 4)
    var tmp = ""
    renderRstSons(d, n, tmp)
    if tmp.len > 0: 
      result.add("\n")
      result.add(ind)
      result.add("(#) ")
      result.add(tmp)
    dec(d.indent, 4)
  of rnOptionList, rnFieldList, rnDefList, rnDefItem, rnLineBlock, rnFieldName, 
     rnFieldBody, rnStandaloneHyperlink, rnBulletList, rnEnumList: 
    renderRstSons(d, n, result)
  of rnDefName: 
    result.add("\n\n")
    result.add(ind)
    renderRstSons(d, n, result)
  of rnDefBody:
    inc(d.indent, 2)
    if n.sons[0].kind != rnBulletList: 
      result.add("\n")
      result.add(ind)
      result.add("  ")
    renderRstSons(d, n, result)
    dec(d.indent, 2)
  of rnField:
    var tmp = ""
    renderRstToRst(d, n.sons[0], tmp)
    
    var L = max(tmp.len + 3, 30)
    inc(d.indent, L)
    
    result.add "\n"
    result.add ind
    result.add ':'
    result.add tmp
    result.add ':'
    result.add repeatChar(L - tmp.len - 2)
    renderRstToRst(d, n.sons[1], result)
    
    dec(d.indent, L)
  of rnLineBlockItem: 
    result.add("\n")
    result.add(ind)
    result.add("| ")
    renderRstSons(d, n, result)
  of rnBlockQuote:
    inc(d.indent, 2)
    renderRstSons(d, n, result)
    dec(d.indent, 2)
  of rnRef: 
    result.add("`")
    renderRstSons(d, n, result)
    result.add("`_")
  of rnHyperlink: 
    result.add('`')
    renderRstToRst(d, n.sons[0], result)
    result.add(" <")
    renderRstToRst(d, n.sons[1], result)
    result.add(">`_")
  of rnGeneralRole:
    result.add('`')
    renderRstToRst(d, n.sons[0],result)
    result.add("`:")
    renderRstToRst(d, n.sons[1],result)
    result.add(':')
  of rnSub: 
    result.add('`')
    renderRstSons(d, n, result)
    result.add("`:sub:")
  of rnSup: 
    result.add('`')
    renderRstSons(d, n, result)
    result.add("`:sup:")
  of rnIdx: 
    result.add('`')
    renderRstSons(d, n, result)
    result.add("`:idx:")
  of rnEmphasis: 
    result.add("*")
    renderRstSons(d, n, result)
    result.add("*")
  of rnStrongEmphasis: 
    result.add("**")
    renderRstSons(d, n, result)
    result.add("**")
  of rnTripleEmphasis:
    result.add("***")
    renderRstSons(d, n, result)
    result.add("***")
  of rnInterpretedText: 
    result.add('`')
    renderRstSons(d, n, result)
    result.add('`')
  of rnInlineLiteral: 
    inc(d.verbatim)
    result.add("``")
    renderRstSons(d, n, result)
    result.add("``")
    dec(d.verbatim)
  of rnSmiley:
    result.add(n.text)
  of rnLeaf:
    if d.verbatim == 0 and n.text == "\\":
      result.add("\\\\") # XXX: escape more special characters!
    else:
      result.add(n.text)
  of rnIndex: 
    result.add("\n\n")
    result.add(ind)
    result.add(".. index::\n")
    
    inc(d.indent, 3)
    if n.sons[2] != nil: renderRstSons(d, n.sons[2], result)
    dec(d.indent, 3)
  of rnContents:
    result.add("\n\n")
    result.add(ind)
    result.add(".. contents::")
  else:
    result.add("Error: cannot render: " & $n.kind)
  
proc renderRstToRst*(n: PRstNode, result: var string) =
  ## renders `n` into its string representation and appends to `result`.
  var d: TRenderContext
  renderRstToRst(d, n, result)

proc renderRstToJsonNode(node: PRstNode): JsonNode =
  result =
    %[
      (key: "kind", val: %($node.kind)),
      (key: "level", val: %BiggestInt(node.level))
     ]
  if node.text != nil:
    result.add("text", %node.text)
  if node.sons != nil and len(node.sons) > 0:
    var accm = newSeq[JsonNode](len(node.sons))
    for i, son in node.sons:
      accm[i] = renderRstToJsonNode(son)
    result.add("sons", %accm)

proc renderRstToJson*(node: PRstNode): string =
  ## Writes the given RST node as JSON that is in the form
  ## :: 
  ##   {
  ##     "kind":string node.kind,
  ##     "text":optional string node.text,
  ##     "level":optional int node.level,
  ##     "sons":optional node array
  ##   }
  renderRstToJsonNode(node).pretty
