# Introdução

Este repositório contém a implementação de um protótipo de uma ferramenta
para geração e execução de testes contra uma API web. Esta ferramenta foi
desenvolvida como projeto da disciplina SIN 5022 do PPgSI (EACH USP).

![](./report_example.png?raw=true)

# Escopo

O protótipo atualmente está dentro de uma aplicação Rails, que implementa
também uma API fictícia para uso nos testes da ferramenta. Tanto a ferramenta
quanto essa API fictícia foram implementadas na linguagem de programação Ruby.

A ferramenta atualmente é bastante limitada e não suporta todas as possibilidades
de uma especificação OpenAPI. Atualmente, a ferramenta é capaz de gerar
e executar testes para alguns tipos de requisição que usem o verbo HTTP GET.
A ferramenta é capaz de fazer isso por meio da leitura de uma especificação
seguindo o padrão OpenAPI.

Ao executar os testes gerados, a ferramenta é capaz de verificar:
1) Se cada requisição teve uma resposta com código 2xx (sucesso); e
2) Se os tipos dos dados de retorno (especificados no arquivo OpenAPI) são de
fato honrados pela implementação de fato da API sob teste.

# Usando a ferramenta

Para usar a ferramenta, baixe este repositório para o seu ambiente local.

Você irá precisar ter a versão 2.5.3 do Ruby (ou superior).

Após baixar o repositório, execute o seguinte comando (dentro do diretório do repositório) para instalar suas
dependências:

```
bundle install
```

Após instalar as dependências, levante a API de exemplo com o seguinte comando:

```
bundle exec rails server
```

Após ter a API rodando localmente, em uma nova aba do seu terminal execute
o seguinte comando:

```
bundle exec rails console
```

O comando anterior levanta um console Rails. Nele, copie, cole e execute
(apertando ENTER) a seguinte linha de código:

```
g = TestGen.new('app/lib/cities_meteorological_info_openapi.yml'); g.generate_and_run_tests
```

Como resultado, o arquivo YAML especificado (descrição OpenAPI da API de exemplo) será
lido e serão gerados e executados testes para a API que já está rodando localmente.
Após a execução do comando, você verá impresso na tela um relatório como o seguinte:

![](./report_example.png?raw=true)
