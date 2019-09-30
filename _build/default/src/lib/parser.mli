
(* The type of tokens. *)

type token = 
  | WHILE
  | VAR
  | TYPE
  | TO
  | TIMES
  | THEN
  | STRING of (string)
  | SEMI
  | RPAREN
  | REAL of (float)
  | RBRACK
  | RBRACE
  | POW
  | PLUS
  | OR
  | OF
  | NIL
  | NE
  | MOD
  | MINUS
  | LT
  | LPAREN
  | LOGIC of (bool)
  | LET
  | LE
  | LBRACK
  | LBRACE
  | INTEGER of (int)
  | IN
  | IF
  | ID of (Symbol.symbol)
  | GT
  | GE
  | FUNCTION
  | FOR
  | EQ
  | EOF
  | END
  | ELSE
  | DOT
  | DO
  | DIV
  | COMMA
  | COLON
  | BREAK
  | BOOL of (bool)
  | ASSIGN
  | ARRAY
  | AND
