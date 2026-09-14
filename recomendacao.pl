% =====================================================================
%  SISTEMA ESPECIALISTA DE RECOMENDAÇÃO ACADÊMICA
%
%  Paradigmas de Linguagens de Programação — Trabalho da G1
%  Grupo 4 · Paradigma LÓGICO · Linguagem PROLOG
%  Integrantes: Rayane · Andrey Vida Leve · Pedro Henrique ·
%               Gabriel Silva · Guilherme Alves
%
%  O QUE ESTE PROGRAMA FAZ
%  Recebe uma base de FATOS (10 disciplinas, seus pré-requisitos e o
%  histórico do aluno João) e INFERE, por REGRAS, em quais disciplinas
%  ele pode se matricular no próximo semestre — e por que as demais
%  estão bloqueadas.
%
%  RESTRIÇÃO TÉCNICA ATENDIDA
%  Não existe aqui nenhum laço, nenhuma variável de controle e nenhuma
%  atribuição. Só FATOS e REGRAS. Quem percorre as alternativas é o
%  motor de inferência do Prolog, por BACKTRACKING.
%
%  COMO EXECUTAR
%      swipl recomendacao.pl
%      ?- boletim(joao).
%      ?- recomendacao(joao).
%      ?- demonstrar_backtracking.
% =====================================================================


% =====================================================================
%  PARTE 1 — FATOS
%  Um fato é uma afirmação incondicional: é verdade, ponto.
% =====================================================================

% ---------------------------------------------------------------------
%  disciplina(Codigo, Nome, Periodo, CargaHoraria).
%  As 10 disciplinas da matriz curricular.
% ---------------------------------------------------------------------
disciplina(alg1,    'Algoritmos e Programação I',      1, 80).
disciplina(mat,     'Matemática Discreta',             1, 60).
disciplina(arq,     'Arquitetura de Computadores',     1, 60).
disciplina(alg2,    'Algoritmos e Programação II',     2, 80).
disciplina(bd,      'Banco de Dados',                  2, 60).
disciplina(eda,     'Estrutura de Dados',              3, 80).
disciplina(poo,     'Programação Orientada a Objetos', 3, 80).
disciplina(so,      'Sistemas Operacionais',           4, 60).
disciplina(redes,   'Redes de Computadores',           4, 60).
disciplina(parad,   'Paradigmas de Linguagens',        5, 60).

% ---------------------------------------------------------------------
%  pre_requisito(Disciplina, PreRequisito).
%  "Para cursar Disciplina é preciso ter sido aprovado em PreRequisito."
%  Uma disciplina pode ter mais de um pré-requisito: basta mais de um
%  fato com o mesmo primeiro argumento (veja eda e parad).
% ---------------------------------------------------------------------
pre_requisito(alg2,  alg1).
pre_requisito(bd,    mat).
pre_requisito(eda,   alg2).
pre_requisito(eda,   mat).
pre_requisito(poo,   alg2).
pre_requisito(so,    arq).
pre_requisito(redes, arq).
pre_requisito(parad, poo).
pre_requisito(parad, eda).

% ---------------------------------------------------------------------
%  cursou(Aluno, Disciplina, Nota).
%  O histórico escolar do aluno João. Note bd com nota 4.0:
%  ele CURSOU, mas não foi aprovado — e é isso que trava a matriz.
% ---------------------------------------------------------------------
cursou(joao, alg1, 8.5).
cursou(joao, mat,  7.0).
cursou(joao, arq,  9.0).
cursou(joao, alg2, 6.5).
cursou(joao, bd,   4.0).

% ---------------------------------------------------------------------
%  Parâmetros da regra acadêmica, também como fatos: mudar a política
%  da faculdade é editar um fato, não reescrever o programa.
% ---------------------------------------------------------------------
nota_minima(6.0).
limite_de_disciplinas(4).


% =====================================================================
%  PARTE 2 — REGRAS
%  Uma regra tem a forma  Cabeca :- Corpo.  e lê-se:
%  "Cabeca é verdade SE Corpo for verdade."
%  A vírgula é E lógico. O \+ é "não é possível provar que".
% =====================================================================

% ---------------------------------------------------------------------
%  aprovado(Aluno, Disciplina)
%  É verdade se o aluno cursou a disciplina E a nota alcançou o mínimo.
% ---------------------------------------------------------------------
aprovado(Aluno, Disciplina) :-
    cursou(Aluno, Disciplina, Nota),
    nota_minima(Minima),
    Nota >= Minima.

% ---------------------------------------------------------------------
%  reprovado(Aluno, Disciplina)
%  Cursou, mas ficou abaixo do mínimo.
% ---------------------------------------------------------------------
reprovado(Aluno, Disciplina) :-
    cursou(Aluno, Disciplina, Nota),
    nota_minima(Minima),
    Nota < Minima.

% ---------------------------------------------------------------------
%  pendente(Aluno, Disciplina)
%  Toda disciplina da matriz em que o aluno AINDA não foi aprovado.
%  Inclui as que ele nunca cursou e as que ele cursou e reprovou.
%
%  Aqui aparece a HIPÓTESE DO MUNDO FECHADO: o Prolog conclui
%  "não aprovado" porque não conseguiu PROVAR "aprovado" na base.
%  O que não está na base é tratado como falso.
% ---------------------------------------------------------------------
pendente(Aluno, Disciplina) :-
    disciplina(Disciplina, _, _, _),
    \+ aprovado(Aluno, Disciplina).

% ---------------------------------------------------------------------
%  pre_requisito_pendente(Aluno, Disciplina, Faltante)
%  Existe algum pré-requisito de Disciplina em que o aluno não foi
%  aprovado? Se houver mais de um, o backtracking devolve um por vez.
% ---------------------------------------------------------------------
pre_requisito_pendente(Aluno, Disciplina, Faltante) :-
    pre_requisito(Disciplina, Faltante),
    \+ aprovado(Aluno, Faltante).

% ---------------------------------------------------------------------
%  liberada(Aluno, Disciplina)
%  Nenhum pré-requisito faltando. Repare que a regra não precisa
%  contar quantos pré-requisitos existem, nem percorrê-los: basta
%  dizer que NÃO existe um faltante.
% ---------------------------------------------------------------------
liberada(Aluno, Disciplina) :-
    disciplina(Disciplina, _, _, _),
    \+ pre_requisito_pendente(Aluno, Disciplina, _).

% ---------------------------------------------------------------------
%  apto(Aluno, Disciplina)   <<< A CONSULTA CENTRAL DO TRABALHO
%  O aluno pode se matricular na disciplina se ela está pendente
%  E está liberada.
% ---------------------------------------------------------------------
apto(Aluno, Disciplina) :-
    pendente(Aluno, Disciplina),
    liberada(Aluno, Disciplina).

% ---------------------------------------------------------------------
%  bloqueada(Aluno, Disciplina, PorCausaDe)
%  O contrário: pendente, mas travada por um pré-requisito específico.
% ---------------------------------------------------------------------
bloqueada(Aluno, Disciplina, PorCausaDe) :-
    pendente(Aluno, Disciplina),
    pre_requisito_pendente(Aluno, Disciplina, PorCausaDe).

% ---------------------------------------------------------------------
%  prioridade(Aluno, Disciplina, Periodo)
%  Entre as aptas, a do período mais baixo vem primeiro: é a que
%  destrava mais coisa lá na frente.
% ---------------------------------------------------------------------
prioridade(Aluno, Disciplina, Periodo) :-
    apto(Aluno, Disciplina),
    disciplina(Disciplina, _, Periodo, _).

% ---------------------------------------------------------------------
%  destrava(Disciplina, Futura)
%  Ser aprovado em Disciplina é condição para cursar Futura.
%  Serve para justificar a prioridade da recomendação.
% ---------------------------------------------------------------------
destrava(Disciplina, Futura) :-
    pre_requisito(Futura, Disciplina).

% ---------------------------------------------------------------------
%  grade_sugerida(Aluno, Disciplinas)
%  O aluno está apto a mais disciplinas do que o limite por semestre.
%  A grade sugerida ordena as aptas por período (as mais atrasadas
%  primeiro, porque destravam mais coisa adiante) e corta no limite.
%
%  findall/3 é a forma declarativa de coletar TODAS as soluções de uma
%  meta: ele mesmo força o backtracking até esgotar as alternativas.
%  Não há laço aqui — há uma descrição do conjunto desejado.
% ---------------------------------------------------------------------
grade_sugerida(Aluno, Disciplinas) :-
    findall(Periodo-D, prioridade(Aluno, D, Periodo), Pares),
    keysort(Pares, Ordenados),
    limite_de_disciplinas(Limite),
    primeiros(Limite, Ordenados, Escolhidos),
    findall(D, member(_-D, Escolhidos), Disciplinas).

% primeiros(N, Lista, Prefixo) — os N primeiros elementos da lista.
% Definido por fatos e regras, com recursão, sem nenhum contador.
primeiros(0, _, []) :- !.
primeiros(_, [], []).
primeiros(N, [X|Resto], [X|Prefixo]) :-
    N > 0,
    Proximo is N - 1,
    primeiros(Proximo, Resto, Prefixo).

% ---------------------------------------------------------------------
%  carga_horaria_total(Aluno, Total)
%  Soma da carga horária da grade sugerida.
%  aggregate_all/3 é o modo declarativo de somar: não há acumulador
%  nem laço, apenas a descrição do conjunto a ser somado.
% ---------------------------------------------------------------------
carga_horaria_total(Aluno, Total) :-
    grade_sugerida(Aluno, Disciplinas),
    aggregate_all(sum(CH),
                  ( member(D, Disciplinas), disciplina(D, _, _, CH) ),
                  Total).


% =====================================================================
%  PARTE 3 — RELATÓRIOS
%  Só apresentam o que as regras acima já inferiram.
% =====================================================================

% ---------------------------------------------------------------------
%  boletim(Aluno) — a situação atual do histórico.
% ---------------------------------------------------------------------
boletim(Aluno) :-
    format('~n=====================================================~n'),
    format(' HISTÓRICO DE ~w~n', [Aluno]),
    format('=====================================================~n'),
    forall(( cursou(Aluno, D, Nota), disciplina(D, Nome, P, _) ),
           ( situacao(Aluno, D, Situacao),
             format('  ~w~t~40| ~wº per.   nota ~1f   ~w~n',
                    [Nome, P, Nota, Situacao]) )),
    format('=====================================================~n').

situacao(Aluno, D, aprovado)  :- aprovado(Aluno, D).
situacao(Aluno, D, reprovado) :- reprovado(Aluno, D).

% ---------------------------------------------------------------------
%  recomendacao(Aluno) — a resposta do sistema especialista.
% ---------------------------------------------------------------------
recomendacao(Aluno) :-
    format('~n============================================================~n'),
    format(' RECOMENDAÇÃO DE MATRÍCULA — PRÓXIMO SEMESTRE~n'),
    format(' Aluno: ~w~n', [Aluno]),
    format('============================================================~n~n'),

    grade_sugerida(Aluno, Grade),
    limite_de_disciplinas(Limite),
    format('GRADE SUGERIDA (limite de ~w disciplinas, período mais baixo primeiro)~n', [Limite]),
    forall(member(D, Grade),
           ( disciplina(D, Nome, P, CH),
             format('  [+] ~w~t~40| ~wº per.  ~wh~n', [Nome, P, CH]),
             justificar_liberacao(Aluno, D) )),

    format('~nAPTA, MAS FORA DO LIMITE DESTE SEMESTRE~n'),
    forall(( prioridade(Aluno, D2, P2), \+ member(D2, Grade) ),
           ( disciplina(D2, Nome2, _, _),
             format('  [ ] ~w~t~40| ~wº per.~n', [Nome2, P2]) )),

    format('~nBLOQUEADAS~n'),
    forall(( disciplina(D3, Nome3, _, _),
             findall(NF, ( bloqueada(Aluno, D3, F),
                           disciplina(F, NF, _, _) ), Faltantes),
             Faltantes \= [] ),
           format('  [-] ~w~t~40| falta: ~w~n', [Nome3, Faltantes])),

    carga_horaria_total(Aluno, Total),
    format('~n------------------------------------------------------------~n'),
    format(' Carga horária da grade sugerida: ~wh~n', [Total]),
    format('============================================================~n').

% Explica por que uma disciplina foi liberada.
justificar_liberacao(_, D) :-
    \+ pre_requisito(D, _),
    format('      sem pré-requisitos na matriz~n').
justificar_liberacao(Aluno, D) :-
    pre_requisito(D, _),
    forall(( pre_requisito(D, P), disciplina(P, NomeP, _, _) ),
           ( cursou(Aluno, P, Nota),
             format('      pré-requisito cumprido: ~w (nota ~1f)~n',
                    [NomeP, Nota]) )).


% =====================================================================
%  PARTE 4 — DEMONSTRAÇÃO DO BACKTRACKING
%  Exigência da restrição técnica: explicar o backtracking na execução.
% =====================================================================

demonstrar_backtracking :-
    format('~n=====================================================~n'),
    format(' COMO O PROLOG CHEGA NA RESPOSTA (BACKTRACKING)~n'),
    format('=====================================================~n~n'),
    format('Pergunta feita ao motor de inferência:~n'),
    format('    ?- apto(joao, D).~n~n'),
    format('Ele NÃO percorre uma lista com um laço. Ele tenta provar~n'),
    format('a meta para o PRIMEIRO fato disciplina/4 que unifica com D,~n'),
    format('e quando falha, VOLTA (backtrack) e tenta o próximo.~n~n'),
    forall(disciplina(D, Nome, _, _), traco(D, Nome)),
    format('~n-----------------------------------------------------~n'),
    format('Cada [FALHA] acima é um retrocesso: o Prolog desfaz a~n'),
    format('amarração de D, volta ao ponto de escolha e tenta o~n'),
    format('próximo fato. Cada [OK] é uma solução — e ele fica~n'),
    format('pronto para retroceder de novo se pedirmos mais uma.~n'),
    format('=====================================================~n').

traco(D, Nome) :-
    (   \+ pendente(joao, D)
    ->  format('  D = ~w~t~14|[FALHA] já aprovado, a meta pendente/2 falha~n', [D])
    ;   pre_requisito_pendente(joao, D, Falta)
    ->  format('  D = ~w~t~14|[FALHA] pré-requisito ~w não aprovado~n', [D, Falta])
    ;   format('  D = ~w~t~14|[ OK  ] ~w~n', [D, Nome])
    ).


% =====================================================================
%  PARTE 5 — ATALHO PARA A APRESENTAÇÃO
% =====================================================================

demo :-
    boletim(joao),
    recomendacao(joao),
    demonstrar_backtracking.

:- initialization(( format('~n'),
                    format('Sistema Especialista de Recomendação Acadêmica~n'),
                    format('Grupo 4 · Paradigma Lógico · Prolog~n~n'),
                    format('Consultas disponíveis:~n'),
                    format('  ?- demo.                     roda tudo~n'),
                    format('  ?- boletim(joao).            histórico~n'),
                    format('  ?- recomendacao(joao).       a resposta do sistema~n'),
                    format('  ?- demonstrar_backtracking.  como ele pensou~n'),
                    format('  ?- apto(joao, D).            uma solução por vez (tecle ;)~n~n') )).
