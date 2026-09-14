% =====================================================================
%  SISTEMA ESPECIALISTA DE RECOMENDACAO ACADEMICA
%  Base de Conhecimento: 10 disciplinas, pre-requisitos e historico
%  Aluno modelo: joao
% =====================================================================
%
%  Como executar (SWI-Prolog):
%    $ swipl recomendacao_academica.pl
%    ?- disciplinas_recomendadas(joao, Lista).
%    ?- apto(joao, redes).
%    ?- explicar(joao, engenharia_software).
%
% =====================================================================

% Garante member/2, append/3 etc. disponiveis (necessario em GNU Prolog;
% inofensivo/redundante em SWI-Prolog, que ja os carrega por padrao).
:- use_module(library(lists)).


% ---------------------------------------------------------------------
% 1. FATOS: disciplinas do curso
% ---------------------------------------------------------------------
% disciplina(Codigo, NomeLegivel).

disciplina(calculo1,            'Calculo I').
disciplina(algoritmos,          'Algoritmos e Programacao').
disciplina(calculo2,            'Calculo II').
disciplina(estrutura_dados,     'Estrutura de Dados').
disciplina(fisica1,             'Fisica I').
disciplina(algebra_linear,      'Algebra Linear').
disciplina(poo,                 'Programacao Orientada a Objetos').
disciplina(banco_dados,         'Banco de Dados').
disciplina(redes,               'Redes de Computadores').
disciplina(engenharia_software, 'Engenharia de Software').


% ---------------------------------------------------------------------
% 2. FATOS: pre-requisitos
% ---------------------------------------------------------------------
% prerequisito(Disciplina, DisciplinaExigidaComoPreRequisito).
% (uma disciplina pode ter 0, 1 ou varios pre-requisitos)

prerequisito(calculo2,            calculo1).
prerequisito(fisica1,             calculo1).
prerequisito(algebra_linear,      calculo1).
prerequisito(estrutura_dados,     algoritmos).
prerequisito(poo,                 estrutura_dados).
prerequisito(banco_dados,         estrutura_dados).
prerequisito(redes,               estrutura_dados).
prerequisito(redes,               algoritmos).
prerequisito(engenharia_software, poo).
prerequisito(engenharia_software, banco_dados).

% calculo1 e algoritmos nao tem pre-requisitos (fatos base da arvore).


% ---------------------------------------------------------------------
% 3. FATOS: historico escolar do aluno Joao
% ---------------------------------------------------------------------
% historico(Aluno, Disciplina, Situacao).
% Situacao pertence a {aprovado, reprovado, cursando}

historico(joao, calculo1,        aprovado).
historico(joao, algoritmos,      aprovado).
historico(joao, calculo2,        aprovado).
historico(joao, estrutura_dados, aprovado).
historico(joao, fisica1,         aprovado).
historico(joao, poo,             reprovado).   % reprovou, precisa refazer
historico(joao, algebra_linear,  cursando).    % cursando neste semestre

% Observacao: banco_dados, redes e engenharia_software ainda nao
% constam no historico de Joao (nunca foram cursadas).


% ---------------------------------------------------------------------
% 4. REGRAS: situacao academica do aluno em uma disciplina
% ---------------------------------------------------------------------

% ja_aprovado/2 - verdadeiro se o aluno ja foi aprovado na disciplina
ja_aprovado(Aluno, Disc) :-
    historico(Aluno, Disc, aprovado).

% ja_cursando/2 - verdadeiro se o aluno esta cursando a disciplina agora
ja_cursando(Aluno, Disc) :-
    historico(Aluno, Disc, cursando).

% ja_reprovado/2 - verdadeiro se o aluno reprovou na disciplina
ja_reprovado(Aluno, Disc) :-
    historico(Aluno, Disc, reprovado).

% concluida/2 - disciplina que nao precisa (nem pode) ser matriculada
%  de novo porque ja foi aprovada
concluida(Aluno, Disc) :-
    ja_aprovado(Aluno, Disc).


% ---------------------------------------------------------------------
% 5. REGRAS: verificacao de pre-requisitos (recursiva com backtracking)
% ---------------------------------------------------------------------

% todos_prerequisitos_ok/2 - percorre TODOS os pre-requisitos de uma
% disciplina e so e verdadeiro se cada um deles ja foi aprovado.
% Aqui o Prolog gera, via backtracking, cada fato prerequisito/2
% que casa com a Disciplina (ponto de escolha) e tenta prova-los.

todos_prerequisitos_ok(_Aluno, Disciplina) :-
    \+ prerequisito(Disciplina, _),   % nao tem pre-requisito -> ok
    !.
todos_prerequisitos_ok(Aluno, Disciplina) :-
    findall(P, prerequisito(Disciplina, P), ListaPrereqs),
    verificar_lista(Aluno, ListaPrereqs).

% verificar_lista/2 - percorre a lista de pre-requisitos um a um.
% Cada chamada recursiva e um ponto onde o Prolog pode falhar e
% retroceder (backtracking) caso algum pre-requisito nao esteja
% aprovado.
verificar_lista(_Aluno, []).
verificar_lista(Aluno, [P|Resto]) :-
    ja_aprovado(Aluno, P),
    verificar_lista(Aluno, Resto).


% ---------------------------------------------------------------------
% 6. REGRA PRINCIPAL: aptidao para matricula
% ---------------------------------------------------------------------
% apto/2 - o aluno pode se matricular na disciplina se:
%   (a) a disciplina existe no curso
%   (b) o aluno ainda NAO foi aprovado nela
%   (c) o aluno NAO esta cursando ela neste exato momento
%   (d) TODOS os pre-requisitos dela ja foram aprovados

apto(Aluno, Disciplina) :-
    disciplina(Disciplina, _),
    \+ ja_aprovado(Aluno, Disciplina),
    \+ ja_cursando(Aluno, Disciplina),
    todos_prerequisitos_ok(Aluno, Disciplina).


% ---------------------------------------------------------------------
% 7. REGRA: lista completa de disciplinas recomendadas
% ---------------------------------------------------------------------
% disciplinas_recomendadas/2 - usa findall/3, que internamente forca o
% Prolog a testar apto/2 para CADA UMA das 10 disciplinas (backtracking
% controlado), coletando as que tiveram sucesso e descartando as que
% falharam.

disciplinas_recomendadas(Aluno, ListaOrdenada) :-
    findall(D-Nome,
            ( disciplina(D, Nome), apto(Aluno, D) ),
            Lista),
    sort(Lista, ListaOrdenada).


% ---------------------------------------------------------------------
% 8. REGRA: explicacao do porque uma disciplina foi ou nao liberada
% (usa write/nl para tornar o raciocinio visivel ao usuario)
% ---------------------------------------------------------------------

explicar(Aluno, Disciplina) :-
    disciplina(Disciplina, Nome),
    format('~n--- Analisando: ~w (~w) ---~n', [Disciplina, Nome]),
    ( ja_aprovado(Aluno, Disciplina)
    -> format('-> Ja aprovado nesta disciplina. Nao precisa cursar novamente.~n', [])
    ;  ( ja_cursando(Aluno, Disciplina)
       -> format('-> Aluno ja esta cursando esta disciplina no momento.~n', [])
       ;  ( findall(P, prerequisito(Disciplina, P), Prereqs),
            ( Prereqs == []
            -> format('-> Disciplina nao possui pre-requisitos.~n', [])
            ;  format('-> Pre-requisitos exigidos: ~w~n', [Prereqs]),
               forall(member(P, Prereqs),
                      ( ( ja_aprovado(Aluno, P)
                        -> format('   [OK] ~w -> aprovado~n', [P])
                        ;  ( ja_reprovado(Aluno, P)
                           -> format('   [FALTA] ~w -> REPROVADO, precisa refazer~n', [P])
                           ;  format('   [FALTA] ~w -> ainda nao cursado/concluido~n', [P])
                           )
                        )
                      ) )
            ),
            ( apto(Aluno, Disciplina)
            -> format('=> RESULTADO: APTO para matricula.~n', [])
            ;  format('=> RESULTADO: NAO APTO para matricula.~n', [])
            )
          )
       )
    ).


% ---------------------------------------------------------------------
% 9. REGRA AUXILIAR: relatorio completo do proximo semestre
% ---------------------------------------------------------------------

relatorio(Aluno) :-
    format('~n=========================================~n', []),
    format(' RELATORIO DE MATRICULA - Aluno: ~w~n', [Aluno]),
    format('=========================================~n', []),
    forall(disciplina(D, _), explicar(Aluno, D)),
    disciplinas_recomendadas(Aluno, Lista),
    format('~n=========================================~n', []),
    format('DISCIPLINAS RECOMENDADAS PARA MATRICULA:~n', []),
    ( Lista == []
    -> format('  Nenhuma disciplina liberada.~n', [])
    ;  forall(member(D-Nome, Lista), format('  * ~w (~w)~n', [D, Nome]))
    ),
    format('=========================================~n~n', []).


% ---------------------------------------------------------------------
% 10. PONTO DE ENTRADA (obrigatorio em compiladores tipo GNU Prolog/gplc,
%     que geram um executavel nativo e chamam main/0 automaticamente;
%     em SWI-Prolog, o initialization/1 tambem dispara isso sozinho
%     assim que o arquivo termina de ser carregado).
% ---------------------------------------------------------------------

main :-
    relatorio(joao),
    halt.

:- initialization(main).

% OBS.: se voce quiser carregar este arquivo no SWI-Prolog para digitar
% consultas manuais no "?-" (ex.: apto(joao, redes).), comente ou remova
% a linha "halt." acima, pois ela encerra o interpretador logo apos
% imprimir o relatorio.
