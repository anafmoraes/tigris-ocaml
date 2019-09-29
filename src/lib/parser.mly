// parser.mly

%token <bool>          LOGIC
%token <int>           INTEGER
%token <string>        STRING
%token <float>         REAL
%token <Symbol.symbol> ID
%token <bool>          BOOL
%token                 IF THEN ELSE
%token                 WHILE DO FOR BREAK
%token                 LET IN END
%token                 VAR
%token                 LPAREN "(" RPAREN ")"
%token                 LBRACK RBRACK LBRACE RBRACE
%token                 DOT
%token                 OF TO NIL
%token                 FUNCTION TYPE ARRAY
%token                 COLON ":" COMMA "," SEMI ";"
%token                 PLUS "+" MINUS "-" TIMES "*" DIV "/" MOD "%" POW "^"
%token                 EQ "=" NE "<>"
%token                 LT "<" LE "<=" GT ">" GE ">="
%token                 AND "&" OR "|"
%token                 ASSIGN ":="
%token                 EOF

%%
