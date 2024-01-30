Definitions.

NUM             = [0-9]+
VAR             = [a-z]
L_BRACE         = [\{\[\(]
R_BRACE         = [\}\]\)]
WHITESPACE      = [\s\t\n\r]


Rules.

e                           : {token, {var, e}}.
pi                          : {token, {var, pi}}.

log{NUM}                    : {token, {func, {log, {num, base(3, TokenChars)}}}}.
log{NUM}[\.{NUM}]?          : {token, {func, {log, {num, base(3, TokenChars)}}}}.
ln|log                      : {token, {func, {log, {num, e}}}}.

sqrt                        : {token, {func, {root, {num, 2}}}}.
root{NUM}[\.{NUM}]?         : {token, {func, {root, {num, base(4, TokenChars)}}}}.

{NUM}                       : {token, {num, list_to_integer(TokenChars)}}.
{NUM}\.{NUM}                : {token, {num, list_to_float(TokenChars)}}.
{VAR}                       : {token, {var, list_to_atom(TokenChars)}}.
{L_BRACE}                   : {token, {'(', '('}}.
{R_BRACE}                   : {token, {')', ')'}}.

[\+?\-?]+                   : {token, {sign(TokenChars), sign(TokenChars)}}.

\*                          : {token, {'*', '*'}}.
\/                          : {token, {'/', '/'}}.
\^                          : {token, {'^', '^'}}.

sin                         : {token, {func, sin}}.
cos                         : {token, {func, cos}}.
tan                         : {token, {func, tan}}.

asin|arcsin                 : {token, {func, asin}}.
acos|arccos                 : {token, {func, acos}}.
atan|arctan                 : {token, {func, atan}}.


{WHITESPACE}+               : skip_token.


Erlang code.

sign(String) ->     {_, Minus} = lists:partition(fun(C) -> C == $+ end, String),
                    case length(Minus) rem 2 of
                      1 -> '-';
                      0 -> '+'
                    end.
base(_i, _stuff) ->  {_, _base} = lists:split(_i, _stuff),
         _result = case lists:member($.,_base) of
                        true -> list_to_float(_base);
                        false -> list_to_integer(_base)
                    end, _result.