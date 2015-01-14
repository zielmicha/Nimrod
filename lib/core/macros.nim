#
#
#            Nim's Runtime Library
#        (c) Copyright 2013 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

include "system/inclrtl"

## This module contains the interface to the compiler's abstract syntax
## tree (`AST`:idx:). Macros operate on this tree.

## .. include:: ../doc/astspec.txt

type
  TNimrodNodeKind* = enum
    nnkNone, nnkEmpty, nnkIdent, nnkSym,
    nnkType, nnkCharLit, nnkIntLit, nnkInt8Lit,
    nnkInt16Lit, nnkInt32Lit, nnkInt64Lit, nnkUIntLit, nnkUInt8Lit,
    nnkUInt16Lit, nnkUInt32Lit, nnkUInt64Lit, nnkFloatLit,
    nnkFloat32Lit, nnkFloat64Lit, nnkFloat128Lit, nnkStrLit, nnkRStrLit,
    nnkTripleStrLit, nnkNilLit, nnkMetaNode, nnkDotCall,
    nnkCommand, nnkCall, nnkCallStrLit, nnkInfix,
    nnkPrefix, nnkPostfix, nnkHiddenCallConv, 
    nnkExprEqExpr,
    nnkExprColonExpr, nnkIdentDefs, nnkVarTuple, 
    nnkPar, nnkObjConstr, nnkCurly, nnkCurlyExpr,
    nnkBracket, nnkBracketExpr, nnkPragmaExpr, nnkRange,
    nnkDotExpr, nnkCheckedFieldExpr, nnkDerefExpr, nnkIfExpr,
    nnkElifExpr, nnkElseExpr, nnkLambda, nnkDo, nnkAccQuoted,
    nnkTableConstr, nnkBind,
    nnkClosedSymChoice,
    nnkOpenSymChoice,
    nnkHiddenStdConv,
    nnkHiddenSubConv, nnkConv, nnkCast, nnkStaticExpr,
    nnkAddr, nnkHiddenAddr, nnkHiddenDeref, nnkObjDownConv,
    nnkObjUpConv, nnkChckRangeF, nnkChckRange64, nnkChckRange,
    nnkStringToCString, nnkCStringToString, nnkAsgn,
    nnkFastAsgn, nnkGenericParams, nnkFormalParams, nnkOfInherit,
    nnkImportAs, nnkProcDef, nnkMethodDef, nnkConverterDef,
    nnkMacroDef, nnkTemplateDef, nnkIteratorDef, nnkOfBranch,
    nnkElifBranch, nnkExceptBranch, nnkElse,
    nnkAsmStmt, nnkPragma, nnkPragmaBlock, nnkIfStmt, nnkWhenStmt,
    nnkForStmt, nnkParForStmt, nnkWhileStmt, nnkCaseStmt,
    nnkTypeSection, nnkVarSection, nnkLetSection, nnkConstSection,
    nnkConstDef, nnkTypeDef,
    nnkYieldStmt, nnkDefer, nnkTryStmt, nnkFinally, nnkRaiseStmt,
    nnkReturnStmt, nnkBreakStmt, nnkContinueStmt, nnkBlockStmt, nnkStaticStmt,
    nnkDiscardStmt, nnkStmtList, 
    nnkImportStmt,
    nnkImportExceptStmt,
    nnkExportStmt,
    nnkExportExceptStmt,
    nnkFromStmt,
    nnkIncludeStmt,
    nnkBindStmt, nnkMixinStmt, nnkUsingStmt,
    nnkCommentStmt, nnkStmtListExpr, nnkBlockExpr,
    nnkStmtListType, nnkBlockType,
    nnkWith, nnkWithout,
    nnkTypeOfExpr, nnkObjectTy,
    nnkTupleTy, nnkTypeClassTy, nnkStaticTy,
    nnkRecList, nnkRecCase, nnkRecWhen,
    nnkRefTy, nnkPtrTy, nnkVarTy,
    nnkConstTy, nnkMutableTy,
    nnkDistinctTy,
    nnkProcTy, 
    nnkIteratorTy,         # iterator type
    nnkSharedTy,           # 'shared T'
    nnkEnumTy,
    nnkEnumFieldDef,
    nnkArglist, nnkPattern
    nnkReturnToken
  TNimNodeKinds* = set[TNimrodNodeKind]
  TNimrodTypeKind* = enum
    ntyNone, ntyBool, ntyChar, ntyEmpty,
    ntyArrayConstr, ntyNil, ntyExpr, ntyStmt,
    ntyTypeDesc, ntyGenericInvokation, ntyGenericBody, ntyGenericInst,
    ntyGenericParam, ntyDistinct, ntyEnum, ntyOrdinal,
    ntyArray, ntyObject, ntyTuple, ntySet,
    ntyRange, ntyPtr, ntyRef, ntyVar,
    ntySequence, ntyProc, ntyPointer, ntyOpenArray,
    ntyString, ntyCString, ntyForward, ntyInt,
    ntyInt8, ntyInt16, ntyInt32, ntyInt64,
    ntyFloat, ntyFloat32, ntyFloat64, ntyFloat128
  TNimTypeKinds* = set[TNimrodTypeKind]
  TNimrodSymKind* = enum
    nskUnknown, nskConditional, nskDynLib, nskParam,
    nskGenericParam, nskTemp, nskModule, nskType, nskVar, nskLet, 
    nskConst, nskResult,
    nskProc, nskMethod, nskIterator, nskClosureIterator,
    nskConverter, nskMacro, nskTemplate, nskField,
    nskEnumField, nskForVar, nskLabel,
    nskStub
    
  TNimSymKinds* = set[TNimrodSymKind]

type
  TNimrodIdent* = object of RootObj
    ## represents a Nimrod identifier in the AST

  TNimrodSymbol {.final.} = object # hidden
  PNimrodSymbol* {.compilerproc.} = ref TNimrodSymbol
    ## represents a Nimrod *symbol* in the compiler; a *symbol* is a looked-up
    ## *ident*.

const
  nnkLiterals* = {nnkCharLit..nnkNilLit}
  nnkCallKinds* = {nnkCall, nnkInfix, nnkPrefix, nnkPostfix, nnkCommand,
                   nnkCallStrLit}

proc `[]`*(n: PNimrodNode, i: int): PNimrodNode {.magic: "NChild", noSideEffect.}
  ## get `n`'s `i`'th child.

proc `[]=`*(n: PNimrodNode, i: int, child: PNimrodNode) {.magic: "NSetChild",
  noSideEffect.}
  ## set `n`'s `i`'th child to `child`.

proc `!`*(s: string): TNimrodIdent {.magic: "StrToIdent", noSideEffect.}
  ## constructs an identifier from the string `s`

proc `$`*(i: TNimrodIdent): string {.magic: "IdentToStr", noSideEffect.}
  ## converts a Nimrod identifier to a string

proc `$`*(s: PNimrodSymbol): string {.magic: "IdentToStr", noSideEffect.}
  ## converts a Nimrod symbol to a string

proc `==`*(a, b: TNimrodIdent): bool {.magic: "EqIdent", noSideEffect.}
  ## compares two Nimrod identifiers

proc `==`*(a, b: PNimrodNode): bool {.magic: "EqNimrodNode", noSideEffect.}
  ## compares two Nimrod nodes

proc len*(n: PNimrodNode): int {.magic: "NLen", noSideEffect.}
  ## returns the number of children of `n`.

proc add*(father, child: PNimrodNode): PNimrodNode {.magic: "NAdd", discardable,
  noSideEffect.}
  ## Adds the `child` to the `father` node. Returns the
  ## father node so that calls can be nested.

proc add*(father: PNimrodNode, children: varargs[PNimrodNode]): PNimrodNode {.
  magic: "NAddMultiple", discardable, noSideEffect.}
  ## Adds each child of `children` to the `father` node.
  ## Returns the `father` node so that calls can be nested.

proc del*(father: PNimrodNode, idx = 0, n = 1) {.magic: "NDel", noSideEffect.}
  ## deletes `n` children of `father` starting at index `idx`.

proc kind*(n: PNimrodNode): TNimrodNodeKind {.magic: "NKind", noSideEffect.}
  ## returns the `kind` of the node `n`.

proc intVal*(n: PNimrodNode): BiggestInt {.magic: "NIntVal", noSideEffect.}
proc floatVal*(n: PNimrodNode): BiggestFloat {.magic: "NFloatVal", noSideEffect.}
proc symbol*(n: PNimrodNode): PNimrodSymbol {.magic: "NSymbol", noSideEffect.}
proc ident*(n: PNimrodNode): TNimrodIdent {.magic: "NIdent", noSideEffect.}
proc typ*(n: PNimrodNode): typedesc {.magic: "NGetType", noSideEffect.}
proc strVal*(n: PNimrodNode): string  {.magic: "NStrVal", noSideEffect.}

proc `intVal=`*(n: PNimrodNode, val: BiggestInt) {.magic: "NSetIntVal", noSideEffect.}
proc `floatVal=`*(n: PNimrodNode, val: BiggestFloat) {.magic: "NSetFloatVal", noSideEffect.}
proc `symbol=`*(n: PNimrodNode, val: PNimrodSymbol) {.magic: "NSetSymbol", noSideEffect.}
proc `ident=`*(n: PNimrodNode, val: TNimrodIdent) {.magic: "NSetIdent", noSideEffect.}
#proc `typ=`*(n: PNimrodNode, typ: typedesc) {.magic: "NSetType".}
# this is not sound! Unfortunately forbidding 'typ=' is not enough, as you
# can easily do:
#   let bracket = semCheck([1, 2])
#   let fake = semCheck(2.0)
#   bracket[0] = fake  # constructs a mixed array with ints and floats!

proc `strVal=`*(n: PNimrodNode, val: string) {.magic: "NSetStrVal", noSideEffect.}

proc newNimNode*(kind: TNimrodNodeKind,
                 n: PNimrodNode=nil): PNimrodNode {.magic: "NNewNimNode", noSideEffect.}

proc copyNimNode*(n: PNimrodNode): PNimrodNode {.magic: "NCopyNimNode", noSideEffect.}
proc copyNimTree*(n: PNimrodNode): PNimrodNode {.magic: "NCopyNimTree", noSideEffect.}

proc error*(msg: string) {.magic: "NError", gcsafe.}
  ## writes an error message at compile time

proc warning*(msg: string) {.magic: "NWarning", gcsafe.}
  ## writes a warning message at compile time

proc hint*(msg: string) {.magic: "NHint", gcsafe.}
  ## writes a hint message at compile time

proc newStrLitNode*(s: string): PNimrodNode {.compileTime, noSideEffect.} =
  ## creates a string literal node from `s`
  result = newNimNode(nnkStrLit)
  result.strVal = s

proc newIntLitNode*(i: BiggestInt): PNimrodNode {.compileTime.} =
  ## creates a int literal node from `i`
  result = newNimNode(nnkIntLit)
  result.intVal = i

proc newFloatLitNode*(f: BiggestFloat): PNimrodNode {.compileTime.} =
  ## creates a float literal node from `f`
  result = newNimNode(nnkFloatLit)
  result.floatVal = f

proc newIdentNode*(i: TNimrodIdent): PNimrodNode {.compileTime.} =
  ## creates an identifier node from `i`
  result = newNimNode(nnkIdent)
  result.ident = i

proc newIdentNode*(i: string): PNimrodNode {.compileTime.} =
  ## creates an identifier node from `i`
  result = newNimNode(nnkIdent)
  result.ident = !i

type
  TBindSymRule* = enum   ## specifies how ``bindSym`` behaves
    brClosed,            ## only the symbols in current scope are bound
    brOpen,              ## open wrt overloaded symbols, but may be a single
                         ## symbol if not ambiguous (the rules match that of
                         ## binding in generics)
    brForceOpen          ## same as brOpen, but it will always be open even
                         ## if not ambiguous (this cannot be achieved with
                         ## any other means in the language currently)

proc bindSym*(ident: string, rule: TBindSymRule = brClosed): PNimrodNode {.
              magic: "NBindSym", noSideEffect.}
  ## creates a node that binds `ident` to a symbol node. The bound symbol
  ## may be an overloaded symbol.
  ## If ``rule == brClosed`` either an ``nkClosedSymChoice`` tree is
  ## returned or ``nkSym`` if the symbol is not ambiguous.
  ## If ``rule == brOpen`` either an ``nkOpenSymChoice`` tree is
  ## returned or ``nkSym`` if the symbol is not ambiguous.
  ## If ``rule == brForceOpen`` always an ``nkOpenSymChoice`` tree is
  ## returned even if the symbol is not ambiguous.

proc genSym*(kind: TNimrodSymKind = nskLet; ident = ""): PNimrodNode {.
  magic: "NGenSym", noSideEffect.}
  ## generates a fresh symbol that is guaranteed to be unique. The symbol
  ## needs to occur in a declaration context.

proc callsite*(): PNimrodNode {.magic: "NCallSite", gcsafe.}
  ## returns the AST if the invokation expression that invoked this macro.

proc toStrLit*(n: PNimrodNode): PNimrodNode {.compileTime.} =
  ## converts the AST `n` to the concrete Nimrod code and wraps that
  ## in a string literal node
  return newStrLitNode(repr(n))

proc lineinfo*(n: PNimrodNode): string {.magic: "NLineInfo", noSideEffect.}
  ## returns the position the node appears in the original source file
  ## in the form filename(line, col)

proc internalParseExpr(s: string): PNimrodNode {.
  magic: "ParseExprToAst", noSideEffect.}

proc internalParseStmt(s: string): PNimrodNode {.
  magic: "ParseStmtToAst", noSideEffect.}

proc internalErrorFlag*(): string {.magic: "NError", noSideEffect.}
  ## Some builtins set an error flag. This is then turned into a proper
  ## exception. **Note**: Ordinary application code should not call this.

proc parseExpr*(s: string): PNimrodNode {.noSideEffect, compileTime.} =
  ## Compiles the passed string to its AST representation.
  ## Expects a single expression. Raises ``ValueError`` for parsing errors.
  result = internalParseExpr(s)
  let x = internalErrorFlag()
  if x.len > 0: raise newException(ValueError, x)

proc parseStmt*(s: string): PNimrodNode {.noSideEffect, compileTime.} =
  ## Compiles the passed string to its AST representation.
  ## Expects one or more statements. Raises ``ValueError`` for parsing errors.
  result = internalParseStmt(s)
  let x = internalErrorFlag()
  if x.len > 0: raise newException(ValueError, x)

proc getAst*(macroOrTemplate: expr): PNimrodNode {.magic: "ExpandToAst", noSideEffect.}
  ## Obtains the AST nodes returned from a macro or template invocation.
  ## Example:
  ##
  ## .. code-block:: nim
  ##
  ##   macro FooMacro() =
  ##     var ast = getAst(BarTemplate())

proc quote*(bl: stmt, op = "``"): PNimrodNode {.magic: "QuoteAst", noSideEffect.}
  ## Quasi-quoting operator.
  ## Accepts an expression or a block and returns the AST that represents it.
  ## Within the quoted AST, you are able to interpolate PNimrodNode expressions
  ## from the surrounding scope. If no operator is given, quoting is done using
  ## backticks. Otherwise, the given operator must be used as a prefix operator
  ## for any interpolated expression. The original meaning of the interpolation
  ## operator may be obtained by escaping it (by prefixing it with itself):
  ## e.g. `@` is escaped as `@@`, `@@` is escaped as `@@@` and so on.
  ##
  ## Example:
  ##   
  ## .. code-block:: nim
  ##
  ##   macro check(ex: expr): stmt =
  ##     # this is a simplified version of the check macro from the
  ##     # unittest module.
  ##
  ##     # If there is a failed check, we want to make it easy for
  ##     # the user to jump to the faulty line in the code, so we
  ##     # get the line info here:
  ##     var info = ex.lineinfo
  ##
  ##     # We will also display the code string of the failed check:
  ##     var expString = ex.toStrLit
  ##
  ##     # Finally we compose the code to implement the check:
  ##     result = quote do:
  ##       if not `ex`:
  ##         echo `info` & ": Check failed: " & `expString`
  
proc expectKind*(n: PNimrodNode, k: TNimrodNodeKind) {.compileTime.} =
  ## checks that `n` is of kind `k`. If this is not the case,
  ## compilation aborts with an error message. This is useful for writing
  ## macros that check the AST that is passed to them.
  if n.kind != k: error("macro expects a node of kind: " & $k)

proc expectMinLen*(n: PNimrodNode, min: int) {.compileTime.} =
  ## checks that `n` has at least `min` children. If this is not the case,
  ## compilation aborts with an error message. This is useful for writing
  ## macros that check its number of arguments.
  if n.len < min: error("macro expects a node with " & $min & " children")

proc expectLen*(n: PNimrodNode, len: int) {.compileTime.} =
  ## checks that `n` has exactly `len` children. If this is not the case,
  ## compilation aborts with an error message. This is useful for writing
  ## macros that check its number of arguments.
  if n.len != len: error("macro expects a node with " & $len & " children")

proc newCall*(theProc: PNimrodNode,
              args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  ## produces a new call node. `theProc` is the proc that is called with
  ## the arguments ``args[0..]``.
  result = newNimNode(nnkCall)
  result.add(theProc)
  result.add(args)

proc newCall*(theProc: TNimrodIdent,
              args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  ## produces a new call node. `theProc` is the proc that is called with
  ## the arguments ``args[0..]``.
  result = newNimNode(nnkCall)
  result.add(newIdentNode(theProc))
  result.add(args)

proc newCall*(theProc: string,
              args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  ## produces a new call node. `theProc` is the proc that is called with
  ## the arguments ``args[0..]``.
  result = newNimNode(nnkCall)
  result.add(newIdentNode(theProc))
  result.add(args)

proc newLit*(c: char): PNimrodNode {.compileTime.} =
  ## produces a new character literal node.
  result = newNimNode(nnkCharLit)
  result.intVal = ord(c)

proc newLit*(i: BiggestInt): PNimrodNode {.compileTime.} =
  ## produces a new integer literal node.
  result = newNimNode(nnkIntLit)
  result.intVal = i

proc newLit*(f: BiggestFloat): PNimrodNode {.compileTime.} =
  ## produces a new float literal node.
  result = newNimNode(nnkFloatLit)
  result.floatVal = f

proc newLit*(s: string): PNimrodNode {.compileTime.} =
  ## produces a new string literal node.
  result = newNimNode(nnkStrLit)
  result.strVal = s

proc nestList*(theProc: TNimrodIdent,
               x: PNimrodNode): PNimrodNode {.compileTime.} =
  ## nests the list `x` into a tree of call expressions:
  ## ``[a, b, c]`` is transformed into ``theProc(a, theProc(c, d))``.
  var L = x.len
  result = newCall(theProc, x[L-2], x[L-1])
  for i in countdown(L-3, 0):
    # XXX the 'copyNimTree' here is necessary due to a bug in the evaluation
    # engine that would otherwise create an endless loop here. :-(
    # This could easily user code and so should be fixed in evals.nim somehow.
    result = newCall(theProc, x[i], copyNimTree(result))

proc treeRepr*(n: PNimrodNode): string {.compileTime.} =
  ## Convert the AST `n` to a human-readable tree-like string.
  ##
  ## See also `repr` and `lispRepr`.
  proc traverse(res: var string, level: int, n: PNimrodNode) =
    for i in 0..level-1: res.add "  "
    res.add(($n.kind).substr(3))

    case n.kind
    of nnkEmpty: discard # same as nil node in this representation
    of nnkNilLit: res.add(" nil")
    of nnkCharLit..nnkInt64Lit: res.add(" " & $n.intVal)
    of nnkFloatLit..nnkFloat64Lit: res.add(" " & $n.floatVal)
    of nnkStrLit..nnkTripleStrLit: res.add(" " & $n.strVal)
    of nnkIdent: res.add(" !\"" & $n.ident & '"')
    of nnkSym: res.add(" \"" & $n.symbol & '"')
    of nnkNone: assert false
    else:
      for j in 0..n.len-1:
        res.add "\n"
        traverse(res, level + 1, n[j])

  result = ""
  traverse(result, 0, n)

proc lispRepr*(n: PNimrodNode): string {.compileTime.} =
  ## Convert the AST `n` to a human-readable lisp-like string,
  ##
  ## See also `repr` and `treeRepr`.

  result = ($n.kind).substr(3)
  add(result, "(")

  case n.kind
  of nnkEmpty: discard # same as nil node in this representation
  of nnkNilLit: add(result, "nil")
  of nnkCharLit..nnkInt64Lit: add(result, $n.intVal)
  of nnkFloatLit..nnkFloat64Lit: add(result, $n.floatVal)
  of nnkStrLit..nnkTripleStrLit: add(result, $n.strVal)
  of nnkIdent: add(result, "!\"" & $n.ident & '"')
  of nnkSym: add(result, $n.symbol)
  of nnkNone: assert false
  else:
    add(result, lispRepr(n[0]))
    for j in 1..n.len-1:
      add(result, ", ")
      add(result, lispRepr(n[j]))

  add(result, ")")

macro dumpTree*(s: stmt): stmt {.immediate.} = echo s.treeRepr
  ## Accepts a block of nim code and prints the parsed abstract syntax
  ## tree using the `toTree` function. Printing is done *at compile time*.
  ##
  ## You can use this as a tool to explore the Nimrod's abstract syntax
  ## tree and to discover what kind of nodes must be created to represent
  ## a certain expression/statement.

macro dumpLisp*(s: stmt): stmt {.immediate.} = echo s.lispRepr
  ## Accepts a block of nim code and prints the parsed abstract syntax
  ## tree using the `toLisp` function. Printing is done *at compile time*.
  ##
  ## See `dumpTree`.

macro dumpTreeImm*(s: stmt): stmt {.immediate, deprecated.} = echo s.treeRepr
  ## The ``immediate`` version of `dumpTree`.

macro dumpLispImm*(s: stmt): stmt {.immediate, deprecated.} = echo s.lispRepr
  ## The ``immediate`` version of `dumpLisp`.


proc newEmptyNode*(): PNimrodNode {.compileTime, noSideEffect.} =
  ## Create a new empty node 
  result = newNimNode(nnkEmpty)

proc newStmtList*(stmts: varargs[PNimrodNode]): PNimrodNode {.compileTime.}=
  ## Create a new statement list
  result = newNimNode(nnkStmtList).add(stmts)

proc newBlockStmt*(label, body: PNimrodNode): PNimrodNode {.compileTime.} =
  ## Create a new block statement with label
  return newNimNode(nnkBlockStmt).add(label, body)

proc newBlockStmt*(body: PNimrodNode): PNimrodNode {.compiletime.} =
  ## Create a new block: stmt
  return newNimNode(nnkBlockStmt).add(newEmptyNode(), body)

proc newVarStmt*(name, value: PNimrodNode): PNimrodNode {.compiletime.} =
  ## Create a new var stmt 
  return newNimNode(nnkVarSection).add(
    newNimNode(nnkIdentDefs).add(name, newNimNode(nnkEmpty), value))

proc newLetStmt*(name, value: PNimrodNode): PNimrodNode {.compiletime.} =
  ## Create a new let stmt 
  return newNimNode(nnkLetSection).add(
    newNimNode(nnkIdentDefs).add(name, newNimNode(nnkEmpty), value))

proc newAssignment*(lhs, rhs: PNimrodNode): PNimrodNode {.compileTime.} =
  return newNimNode(nnkAsgn).add(lhs, rhs)

proc newDotExpr*(a, b: PNimrodNode): PNimrodNode {.compileTime.} = 
  ## Create new dot expression
  ## a.dot(b) ->  `a.b`
  return newNimNode(nnkDotExpr).add(a, b)

proc newIdentDefs*(name, kind: PNimrodNode; 
                   default = newEmptyNode()): PNimrodNode {.compileTime.} = 
  ## Creates a new ``nnkIdentDefs`` node of a specific kind and value.
  ##
  ## ``nnkIdentDefs`` need to have at least three children, but they can have
  ## more: first comes a list of identifiers followed by a type and value
  ## nodes. This helper proc creates a three node subtree, the first subnode
  ## being a single identifier name. Both the ``kind`` node and ``default``
  ## (value) nodes may be empty depending on where the ``nnkIdentDefs``
  ## appears: tuple or object definitions will have an empty ``default`` node,
  ## ``let`` or ``var`` blocks may have an empty ``kind`` node if the
  ## identifier is being assigned a value. Example:
  ##
  ## .. code-block:: nim
  ##
  ##   var varSection = newNimNode(nnkVarSection).add(
  ##     newIdentDefs(ident("a"), ident("string")),
  ##     newIdentDefs(ident("b"), newEmptyNode(), newLit(3)))
  ##   # --> var
  ##   #       a: string
  ##   #       b = 3
  ##
  ## If you need to create multiple identifiers you need to use the lower level
  ## ``newNimNode``:
  ##
  ## .. code-block:: nim
  ##
  ##   result = newNimNode(nnkIdentDefs).add(
  ##     ident("a"), ident("b"), ident("c"), ident("string"),
  ##       newStrLitNode("Hello"))
  newNimNode(nnkIdentDefs).add(name, kind, default)

proc newNilLit*(): PNimrodNode {.compileTime.} =
  ## New nil literal shortcut
  result = newNimNode(nnkNilLit)

proc high*(node: PNimrodNode): int {.compileTime.} = len(node) - 1
  ## Return the highest index available for a node
proc last*(node: PNimrodNode): PNimrodNode {.compileTime.} = node[node.high]
  ## Return the last item in nodes children. Same as `node[node.high()]` 


const
  RoutineNodes* = {nnkProcDef, nnkMethodDef, nnkDo, nnkLambda, nnkIteratorDef}
  AtomicNodes* = {nnkNone..nnkNilLit}
  CallNodes* = {nnkCall, nnkInfix, nnkPrefix, nnkPostfix, nnkCommand, 
    nnkCallStrLit, nnkHiddenCallConv}

from strutils import cmpIgnoreStyle, format

proc expectKind*(n: PNimrodNode; k: set[TNimrodNodeKind]) {.compileTime.} =
  assert n.kind in k, "Expected one of $1, got $2".format(k, n.kind)

proc newProc*(name = newEmptyNode(); params: openArray[PNimrodNode] = [newEmptyNode()];  
    body: PNimrodNode = newStmtList(), procType = nnkProcDef): PNimrodNode {.compileTime.} =
  ## shortcut for creating a new proc
  ##
  ## The ``params`` array must start with the return type of the proc, 
  ## followed by a list of IdentDefs which specify the params.
  assert procType in RoutineNodes
  result = newNimNode(procType).add(
    name,
    newEmptyNode(),
    newEmptyNode(),
    newNimNode(nnkFormalParams).add(params), ##params
    newEmptyNode(),  ## pragmas
    newEmptyNode(),
    body)

proc newIfStmt*(branches: varargs[tuple[cond, body: PNimrodNode]]): 
                PNimrodNode {.compiletime.} =
  ## Constructor for ``if`` statements.
  ##
  ## .. code-block:: nim
  ##    
  ##    newIfStmt(
  ##      (Ident, StmtList),
  ##      ...
  ##    )
  ##
  result = newNimNode(nnkIfStmt)
  for i in branches:
    result.add(newNimNode(nnkElifBranch).add(i.cond, i.body))
    

proc copyChildrenTo*(src, dest: PNimrodNode) {.compileTime.}=
  ## Copy all children from `src` to `dest`
  for i in 0 .. < src.len:
    dest.add src[i].copyNimTree

template expectRoutine(node: PNimrodNode): stmt =
  expectKind(node, RoutineNodes)
  
proc name*(someProc: PNimrodNode): PNimrodNode {.compileTime.} =
  someProc.expectRoutine
  result = someProc[0]
proc `name=`*(someProc: PNimrodNode; val: PNimrodNode) {.compileTime.} =
  someProc.expectRoutine
  someProc[0] = val

proc params*(someProc: PNimrodNode): PNimrodNode {.compileTime.} =
  someProc.expectRoutine
  result = someProc[3]
proc `params=`* (someProc: PNimrodNode; params: PNimrodNode) {.compileTime.}=
  someProc.expectRoutine
  assert params.kind == nnkFormalParams
  someProc[3] = params

proc pragma*(someProc: PNimrodNode): PNimrodNode {.compileTime.} =
  ## Get the pragma of a proc type
  ## These will be expanded
  someProc.expectRoutine
  result = someProc[4]
proc `pragma=`*(someProc: PNimrodNode; val: PNimrodNode){.compileTime.}=
  ## Set the pragma of a proc type
  someProc.expectRoutine
  assert val.kind in {nnkEmpty, nnkPragma}
  someProc[4] = val


template badNodeKind(k; f): stmt{.immediate.} =
  assert false, "Invalid node kind $# for macros.`$2`".format(k, f)

proc body*(someProc: PNimrodNode): PNimrodNode {.compileTime.} =
  case someProc.kind:
  of RoutineNodes:
    return someProc[6]
  of nnkBlockStmt, nnkWhileStmt:
    return someProc[1]
  of nnkForStmt:
    return someProc.last
  else: 
    badNodeKind someProc.kind, "body"

proc `body=`*(someProc: PNimrodNode, val: PNimrodNode) {.compileTime.} =
  case someProc.kind 
  of RoutineNodes:
    someProc[6] = val
  of nnkBlockStmt, nnkWhileStmt:
    someProc[1] = val
  of nnkForStmt:
    someProc[high(someProc)] = val
  else:
    badNodeKind someProc.kind, "body=" 

proc basename*(a: PNimrodNode): PNimrodNode {.compiletime.}
  

proc `$`*(node: PNimrodNode): string {.compileTime.} =
  ## Get the string of an identifier node
  case node.kind
  of nnkIdent:
    result = $node.ident
  of nnkPostfix:
    result = $node.basename.ident & "*"
  of nnkStrLit..nnkTripleStrLit:
    result = node.strVal
  of nnkSym:
    result = $node.symbol
  else: 
    badNodeKind node.kind, "$"

proc ident*(name: string): PNimrodNode {.compileTime,inline.} = newIdentNode(name)
  ## Create a new ident node from a string

iterator children*(n: PNimrodNode): PNimrodNode {.inline.}=
  for i in 0 .. high(n):
    yield n[i]

template findChild*(n: PNimrodNode; cond: expr): PNimrodNode {.
  immediate, dirty.} =
  ## Find the first child node matching condition (or nil).
  ## 
  ## .. code-block:: nim
  ##   var res = findChild(n, it.kind == nnkPostfix and
  ##                          it.basename.ident == !"foo")
  block:
    var result: PNimrodNode
    for it in n.children:
      if cond: 
        result = it
        break
    result

proc insert*(a: PNimrodNode; pos: int; b: PNimrodNode) {.compileTime.} =
  ## Insert node B into A at pos
  if high(a) < pos:
    ## add some empty nodes first
    for i in high(a)..pos-2:
      a.add newEmptyNode()
    a.add b
  else:
    ## push the last item onto the list again
    ## and shift each item down to pos up one
    a.add(a[a.high])
    for i in countdown(high(a) - 2, pos):
      a[i + 1] = a[i]
    a[pos] = b

proc basename*(a: PNimrodNode): PNimrodNode =
  ## Pull an identifier from prefix/postfix expressions
  case a.kind
  of nnkIdent: return a
  of nnkPostfix, nnkPrefix: return a[1]
  else: 
    quit "Do not know how to get basename of ("& treeRepr(a) &")\n"& repr(a)
    
proc `basename=`*(a: PNimrodNode; val: string) {.compileTime.}=
  case a.kind
  of nnkIdent: macros.`ident=`(a,  !val)
  of nnkPostfix, nnkPrefix: a[1] = ident(val)
  else:
    quit "Do not know how to get basename of ("& treeRepr(a)& ")\n"& repr(a)

proc postfix*(node: PNimrodNode; op: string): PNimrodNode {.compileTime.} = 
  newNimNode(nnkPostfix).add(ident(op), node)

proc prefix*(node: PNimrodNode; op: string): PNimrodNode {.compileTime.} = 
  newNimNode(nnkPrefix).add(ident(op), node)

proc infix*(a: PNimrodNode; op: string; 
            b: PNimrodNode): PNimrodNode {.compileTime.} = 
  newNimNode(nnkInfix).add(ident(op), a, b)

proc unpackPostfix*(node: PNimrodNode): tuple[node: PNimrodNode; op: string] {.
  compileTime.} =
  node.expectKind nnkPostfix
  result = (node[0], $node[1])

proc unpackPrefix*(node: PNimrodNode): tuple[node: PNimrodNode; op: string] {.
  compileTime.} =
  node.expectKind nnkPrefix
  result = (node[0], $node[1])

proc unpackInfix*(node: PNimrodNode): tuple[left: PNimrodNode; op: string; 
                                        right: PNimrodNode] {.compileTime.} =
  assert node.kind == nnkInfix
  result = (node[0], $node[1], node[2])

proc copy*(node: PNimrodNode): PNimrodNode {.compileTime.} =
  ## An alias for copyNimTree().
  return node.copyNimTree()

proc eqIdent* (a, b: string): bool = cmpIgnoreStyle(a, b) == 0
  ## Check if two idents are identical.

proc hasArgOfName* (params: PNimrodNode; name: string): bool {.compiletime.}=
  ## Search nnkFormalParams for an argument.
  assert params.kind == nnkFormalParams
  for i in 1 .. <params.len: 
    template node: expr = params[i]
    if name.eqIdent( $ node[0]):
      return true

proc addIdentIfAbsent*(dest: PNimrodNode, ident: string) {.compiletime.} =
  ## Add ident to dest if it is not present. This is intended for use
  ## with pragmas.
  for node in dest.children:
    case node.kind
    of nnkIdent:
      if ident.eqIdent($node): return
    of nnkExprColonExpr:
      if ident.eqIdent($node[0]): return
    else: discard
  dest.add(ident(ident))

when not defined(booting):
  template emit*(e: static[string]): stmt =
    ## accepts a single string argument and treats it as nim code
    ## that should be inserted verbatim in the program
    ## Example:
    ##
    ## .. code-block:: nim
    ##   emit("echo " & '"' & "hello world".toUpper & '"')
    ##
    macro payload: stmt {.gensym.} =
      result = parseStmt(e)
    payload()
