## EBNF representation of our language

```(*
LEXICAL NOTE :
-Comments start with "//" and run till the end of the line.
- Identifiers CANNOT begin with an underscore.
*)
program        = { function | statement } ;
function       = "fn" return_type identifier "(" [ parameters ] ")" block ;
return_type    = type | "void" ;
parameters     = parameter { "," parameter } ;
parameter      = type identifier ;
block          = "{" { statement } "}" ;

(*for arrays we do int[3] arr={1,2,3} //smth like this *)
type           = ( "int" | "bool" | "string" ) [ "[" number "]" ] ;
var_decl = type identifier [ "=" ( expression | array_initializer ) ] ";" ;
array_initializer = "{" expression { "," expression } "}" ;

statement      = var_decl | assignment | call_stmt | if_stmt | while_stmt | return_stmt ;

assignment     = identifier [ "[" expression "]" ] ( "=" | "+=" | "-=" ) expression ";" ;
call_stmt      = func_call ";" ;
if_stmt        = "if" "(" expression ")" block [ "else" block ] ;
while_stmt     = "while" "(" expression ")" block ;
return_stmt    = "return" expression ";" ;

expression     = equality ;
equality       = comparison { ( "==" | "!=" ) comparison } ;
comparison     = term { ( "<" | "<=" | ">" | ">=" ) term } ;
term           = factor { ( "+" | "-" ) factor } ;
factor         = primary { ( "*" | "/" | "%" ) primary } ;

primary        = number | string_literal | "true" | "false" | func_call | identifier | "(" expression ")" ;

func_call           = identifier "(" [ arguments ] ")" ;
arguments      = expression { "," expression } ;

identifier     = letter ,{ letter | digit | "_" } ;
number         = digit { digit } ;
string_literal = '"' { string_char | escape_sequence | interpolation } '"' ;
escape_sequence = "\" ( "n" | "t" | "r" | '"' | "\" ) ;
interpolation  = "{" identifier "}" ;

digit          = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
letter         = "a".."z" | "A".."Z" ;
string_char     = ? any character except '"' or '\' or newline ? ;
