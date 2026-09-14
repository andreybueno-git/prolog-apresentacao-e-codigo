# Prolog: apresentação e código

Material do **Grupo 4** para o trabalho de Paradigmas de Linguagens de Programação: apresentação sobre Prolog e exemplos de um sistema especialista de recomendação acadêmica.

**[Abrir a apresentação](https://andreybueno-git.github.io/prolog-apresentacao-e-codigo/)**

## Arquivos

| Arquivo | Conteúdo |
| --- | --- |
| [index.html](index.html) | Apresentação com os seis tópicos e demonstração visual de backtracking. |
| [abertura.css](abertura.css), [fluido.js](fluido.js) e [assets](assets) | Abertura em vídeo, estilos e efeito visual interativo da apresentação. |
| [recomendacao_academica.pl](recomendacao_academica.pl) | Código enviado por Andrey, com histórico por situação: aprovado, reprovado ou cursando. |
| [recomendacao.pl](recomendacao.pl) | Exemplo original que acompanha os slides, com histórico por notas. |

Os dois programas possuem bases de conhecimento e predicados diferentes. **Carregue apenas um deles por sessão do Prolog.**

## Apresentação

A abertura traz um vídeo de seis segundos, gerado no Higgsfield: uma gota de tinta forma uma árvore e se transforma em uma coruja. O vídeo ocupa a tela inteira e termina antes de abrir os slides. Use **Pular abertura** ou `Esc` para entrar antes.

A reprodução é silenciosa. Em telas estreitas, as laterais são recortadas para preencher a tela sem distorção. A preferência por movimento reduzido é respeitada; se o vídeo não carregar, a apresentação continua acessível.

Abra o link acima ou sirva os arquivos localmente, na pasta deste repositório:

```sh
python3 -m http.server 8000
```

Depois acesse [localhost:8000](http://localhost:8000/).

Use as setas do teclado, `PageUp` / `PageDown` ou espaço para navegar. `Home` e `End` vão para o início e o fim. Na demonstração interativa, use **Próximo passo**, **Rodar tudo** ou **Reiniciar**.

| Tópico | Responsável |
| --- | --- |
| Histórico e criação | Rayane |
| Paradigma lógico | Andrey Vida Leve |
| Características e critérios | Pedro Henrique |
| Sintaxe e semântica | Gabriel Silva |
| Abstração e amarração | Guilherme Alves |
| Compilação e interpretação | Rayane |

## Código enviado: recomendacao_academica.pl

Requer [SWI-Prolog](https://www.swi-prolog.org/). Na pasta do repositório, execute:

```sh
swipl recomendacao_academica.pl
```

O programa imprime o relatório de João e encerra, porque `main` chama `halt` após apresentar os resultados.

A regra `apto/2` verifica quatro condições:

1. A disciplina existe no curso.
2. O aluno ainda não foi aprovado nela.
3. O aluno não está cursando essa disciplina.
4. Todos os seus pré-requisitos diretos foram aprovados.

Com os fatos deste arquivo, João reprovou em **POO** e está cursando **Álgebra Linear**. O relatório recomenda:

- Banco de Dados;
- Programação Orientada a Objetos;
- Redes de Computadores.

Engenharia de Software fica bloqueada porque faltam aprovações em POO e Banco de Dados.

### Consultas interativas

Para estudar, faça uma cópia do arquivo, por exemplo `recomendacao_estudo.pl`. Na cópia, comente a diretiva de inicialização:

```prolog
% :- initialization(main).
```

Carregue a cópia:

```sh
swipl recomendacao_estudo.pl
```

No prompt do Prolog, experimente:

```prolog
apto(joao, redes).
apto(joao, D).
disciplinas_recomendadas(joao, Lista).
explicar(joao, engenharia_software).
relatorio(joao).
```

Pressione `;` para pedir outra solução quando houver alternativas. Use `halt.` para sair. Não chame `main.` durante os exercícios, pois ele encerra a sessão.

Comentar somente `halt.` deixaria uma vírgula pendente na definição de `main`. Por isso, a orientação para estudo é comentar a diretiva inteira em uma cópia.

## Exemplo dos slides: recomendacao.pl

Em outra sessão, execute:

```sh
swipl recomendacao.pl
```

Consultas disponíveis:

```prolog
demo.
boletim(joao).
recomendacao(joao).
demonstrar_backtracking.
apto(joao, D).
grade_sugerida(joao, G).
carga_horaria_total(joao, T).
```

Este exemplo usa notas e mostra João reprovado em **Banco de Dados com 4,0**. Há cinco disciplinas aptas: Banco de Dados, Estrutura de Dados, POO, Sistemas Operacionais e Redes. A grade sugerida aplica o limite de quatro disciplinas e retorna as quatro primeiras, totalizando 280 horas. Redes é elegível, mas fica fora dessa grade; Paradigmas está bloqueada por falta de POO e Estrutura de Dados.

Esses são os dados do exemplo que acompanha os slides. São diferentes dos dados e critérios de `recomendacao_academica.pl`.

## Sobre os materiais

A apresentação, seus recursos visuais originais e `recomendacao.pl` vieram do [repositório original da apresentação](https://github.com/andreybueno-git/paradigmas-prolog). `recomendacao_academica.pl` foi incluído conforme o arquivo enviado por Andrey.

Integrantes: Rayane, Andrey Vida Leve, Pedro Henrique, Gabriel Silva e Guilherme Alves. Professora: Fernanda Pereira Gomes.

Os sistemas são exemplos didáticos: as respostas são calculadas a partir dos fatos cadastrados. Eles não realizam matrículas nem consultam vagas, horários ou sistemas acadêmicos externos.
