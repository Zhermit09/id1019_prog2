Definitions.

NUM        = [0-9]+
VAR        = [a-z]
OP         = [+\-*\/\^]
L_BRACE    = [\{\[\(]
R_BRACE    = [\}\]\)]
WHITESPACE = [\s\t\n\r]

Rules.

{NUM}         : {token, {num, list_to_integer(TokenChars)}}.
{VAR}         : {token, {var, TokenChars}}.
{OP}          : {token, {op, TokenChars}}.
{L_BRACE}     : {token, {l_brace}}.
{R_BRACE}     : {token, {r_brace}}.

{WHITESPACE}+ : skip_token.

Erlang code.
