Nonterminals expr minus.
Terminals num var '+' '-' '*' '/' '^' '(' ')' func.
Rootsymbol expr.


Unary   50     minus.
Left    100     '+'.
Right   100     '-'.
Right   150     num.
Left    175     '/'.
Right   199     expr.
Left    200     '*'.
Left    300     '^'.

Right   400     '('.
Left    400     ')'.

Right   500     func.


expr -> num                     : '$1'.
expr -> var                     : '$1'.
expr -> '(' expr ')'            : '$2'.

expr -> expr '+' expr           : {'+', '$1', '$3'}.
expr -> expr '-' expr           : {'-', '$1', '$3'}.
minus -> '-' expr               : {'-', {num, 0},'$2'}.
expr -> minus                   : '$1'.

expr -> expr '*' expr           : {'*', '$1', '$3'}.
expr -> num expr                : {'*', '$1', '$2'}.
expr -> expr expr               : {'*', '$1', '$2'}.
expr -> expr '/' expr           : {'/', '$1', '$3'}.
expr -> expr '^' expr           : {'^', '$1', '$3'}.

expr -> func expr               : {element(2, '$1'), '$2'}.


Erlang code.