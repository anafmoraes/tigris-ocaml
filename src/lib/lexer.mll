{
  module L = Lexing

  type token = [%import: Parser.token] [@@deriving show]

  let illegal_character loc char =
    Error.error loc "illegal character '%c'" char

  let unterminated_comment loc =
    Error.error loc "unterminated comment"

  let unterminated_string loc =
    Error.error loc "unterminated string"

  let illegal_escape loc sequence =
    Error.error loc "illegal escape sequence '%s' in string literal" sequence

  let set_filename lexbuf fname =
    lexbuf.L.lex_curr_p <-  
      { lexbuf.L.lex_curr_p with L.pos_fname = fname }

  (* a string buffer to accumulate characters when scanning string literals *)
  let string_buffer = Buffer.create 16

  (* helper function to update new line counting while scanning string literals *)
  let str_incr_linenum str lexbuf =
    String.iter (function '\n' -> L.new_line lexbuf | _ -> ()) str
}

let spaces = [' ' '\t'] +
let digit = ['0'-'9']
let litint = digit +

let alphanumeric = ['a'-'z' 'A'-'Z']+
let id = alphanumeric + (alphanumeric|litint|'_')*

let float = digit* ['.'] digit*
let float1 = ( (digit+ "." digit*) | (digit* "." digit+) (['e' 'E'] ['+''-']? digit+)?)
         | (digit+ ['e' 'E'] ['+''-']? digit+)
let real = float1 +

let bool = ("false"|"true")

rule token = parse
  | spaces        { token lexbuf }
  | '\n'          { L.new_line lexbuf;
                    token lexbuf }
  | "{#"          { comment_lexer 0 lexbuf}
  | "#"           { comment_line lexbuf}
  | litint as lxm { INTEGER (int_of_string lxm) }
  | id as lxm     { ID (Symbol.symbol lxm) }
  | real as lxm   { REAL (float_of_string lxm) }
  | bool as lxm   { BOOL (bool_of_string lxm) }
  | '"'           { string lexbuf.L.lex_start_p lexbuf }
  | "for"         { FOR }
  | "while"       { WHILE }
  | "break"       { BREAK }
  | "let"         { LET }
  | "in"          { IN }
  | "nil"         { NIL }
  | "to"          { TO }
  | "end"         { END }
  | "function"    { FUNCTION }
  | "var"         { VAR }
  | "type"        { TYPE }
  | "array"       { ARRAY }
  | "if"          { IF }
  | "then"        { THEN }
  | "else"        { ELSE }
  | "do"          { DO }
  | "of"          { OF }
  | '('           { LPAREN }
  | ')'           { RPAREN }
  | '['           { LBRACK }
  | ']'           { RBRACK }
  | '{'           { LBRACE }
  | '}'           { RBRACE }
  | '.'           { DOT }
  | ':'           { COLON }
  | ','           { COMMA }
  | ';'           { SEMI }
  | '+'           { PLUS }
  | '-'           { MINUS }
  | '*'           { TIMES }
  | '/'           { DIV }
  | '='           { EQ }
  | "<>"          { NE }
  | '<'           { LT }
  | "<="          { LE }
  | '>'           { GT }
  | ">="          { GE }
  | '&'           { AND }
  | '|'           { OR }
  | ":="          { ASSIGN }
  | eof           { EOF }
  | _             { illegal_character (Location.curr_loc lexbuf) (L.lexeme_char lexbuf 0) }

and string pos = parse
| '"'                  { lexbuf.L.lex_start_p <- pos;
                         let text = Buffer.contents string_buffer in
                         Buffer.clear string_buffer;
                         STRING text }
|"\\\""              { Buffer.add_char string_buffer '/'; string pos lexbuf }
| '\\' '\\'            { Buffer.add_char string_buffer '\\'; string pos lexbuf }
| '\\' 'b'             { Buffer.add_char string_buffer '\b'; string pos lexbuf }
| '\\' 'f'             { Buffer.add_char string_buffer '\012'; string pos lexbuf }
| '\\' 'n'             { Buffer.add_char string_buffer '\n'; string pos lexbuf }
| '\\' 'r'             { Buffer.add_char string_buffer '\r'; string pos lexbuf }
| '\\' 'v'             { Buffer.add_char string_buffer '\v'; string pos lexbuf }
| "\\" (digit digit digit as x) { string pos (append_char buf (int_of_string x)) lexbuf }
| '\\' 't'               { Buffer.add_char string_buffer '\t';
                         string pos lexbuf }
| '\\' '^' (['A'-'Z' '@' '[' '\\' ']' '^' '_' '?'] as c)     { Buffer.add_char string_buffer c; string pos lexbuf }
| [^ '\\' '"']+ as lxm { str_incr_linenum lxm lexbuf;
                         Buffer.add_string string_buffer lxm;
                         string pos lexbuf }
| eof                  { illegal_escape (Location.curr_loc lexbuf) }

and comment_lexer size =
      parse
      | "{#" { comment_lexer (size+1) lexbuf }
      | "#}" { if size = 0 then token lexbuf else comment_lexer (size-1) lexbuf }
      | eof  { unterminated_comment (Location.curr_loc lexbuf) }
      | _ { comment_lexer size lexbuf }
and comment_line =
      parse
      | "\n" {  token lexbuf}
      | eof  { unterminated_comment (Location.curr_loc lexbuf) }
      | _ { comment_line lexbuf }
