Definitions.

NUM             = [0-9]+
VAR             = [a-z]
L_BRACE         = [\{\[\(]
R_BRACE         = [\}\]\)]
WHITESPACE      = [\s\t\n\r]


Rules.

{NUM}           : {token, {num, list_to_integer(TokenChars)}}.
{NUM}\.{NUM}    : {token, {num, list_to_float(TokenChars)}}.
{VAR}           : {token, {var, TokenChars}}.
{L_BRACE}       : {token, {'(', '('}}.
{R_BRACE}       : {token, {')', ')'}}.

\+              : {token, {'+', '+'}}.
\-              : {token, {'-', '-'}}.
\*              : {token, {'*', '*'}}.
\/              : {token, {'/', '/'}}.
\^              : {token, {'^', '^'}}.

ln|log          : {token, {func, {log, {num, e}}}}.
log{NUM}        : {token, {func, {log, {num, list_to_float(TokenChars)}}}}.

sin             : {token, {func, sin}}.
cos             : {token, {func, cos}}.
tan             : {token, {func, tan}}.

asin|arcsin     : {token, {func, asin}}.
acos|arccos     : {token, {func, acos}}.
atan|arctan     : {token, {func, atan}}.

sqrt            : {token, {func, {root, {num, 2}}}}.
root{NUM}       : {token, {func, {root, {num, list_to_float(TokenChars)}}}}.

{WHITESPACE}+   : skip_token.


Erlang code.