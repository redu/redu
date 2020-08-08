# Changelog

As mudanças notáveis aplicadas ao Openredu estão documentadas aqui.

O formato deste arquivo é baseado no [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
e a nomenclatura dos nossos releases adere ao padrão [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Adições

- API: Cadastro de usuários via API [#287]
- Download de apresentações [#286]
- Questão com imagem [#60]

## [1.2.0] - 2020-08-08

### Correções

- Texto de boas vindas quando conta já está ativa [#294]

### Contribuições :heart:

|-|Commits|Arquivos modificados|Linhas adicionadas|Linhas removidas|
|-|-|-|-|-|
|Matheus Santana|7|8 | 231 | 4 |

## [1.1.0] - 2020-07-18

### Adições

- API: Porcentagem de conclusão da aula [#288](https://github.com/Openredu/Openredu/pull/288)
- Ativação automática de conta de usuário [#261](https://github.com/Openredu/Openredu/pull/261)
- Validação de unicidade para nomes de audiências [#225](https://github.com/Openredu/Openredu/pull/225)
- Setup da aplicação com o Docker [#221](https://github.com/Openredu/Openredu/pull/221) [#226](https://github.com/Openredu/Openredu/pull/226)
- Mensagens instantâneas (chat) com Faye [#204](https://github.com/Openredu/Openredu/pull/204) [#212](https://github.com/Openredu/Openredu/pull/212)
- Exibição da versão da aplicação [#192](https://github.com/Openredu/Openredu/pull/192)
- Exercícios com o CKEditor [#174](https://github.com/Openredu/Openredu/pull/174)
- Arquivos de configuração do ambiente de execução [#173](https://github.com/Openredu/Openredu/pull/173) [#211](https://github.com/Openredu/Openredu/pull/211)
- Nova landing [#159](https://github.com/Openredu/Openredu/pull/159)
- Serviço para conversão de ppt e pptx em pdf (livredoc) [#125](https://github.com/Openredu/Openredu/pull/125)

### Alterações

- Redes sociais (Instagram em vez de Orkut) [#290](https://github.com/Openredu/Openredu/pull/290)
- Formato de celular com 9 dígitos [#289](https://github.com/Openredu/Openredu/pull/289)
- Ordem de listagem de disciplinas [#262](https://github.com/Openredu/Openredu/pull/262)
- Documentação [#259](https://github.com/Openredu/Openredu/pull/259) [#260](https://github.com/Openredu/Openredu/pull/260) [#269](https://github.com/Openredu/Openredu/pull/269) [#283](https://github.com/Openredu/Openredu/pull/283)
- Configuração do Google Analytics [#164](https://github.com/Openredu/Openredu/pull/164)
- Aumento de limite de caracteres em textos de respostas e status [#139](https://github.com/Openredu/Openredu/pull/139)
- Renomeação de Redu para Openredu / nome parametrizável [#126](https://github.com/Openredu/Openredu/pull/126) [#201](https://github.com/Openredu/Openredu/pull/201)

### Correções

- Aulas em PDF [#206](https://github.com/Openredu/Openredu/pull/206) [#207](https://github.com/Openredu/Openredu/pull/207)
- Checagem da pergunta de segurança na criação de conta [#170](https://github.com/Openredu/Openredu/pull/170)
- Dashboard de analytics [#161](https://github.com/Openredu/Openredu/pull/161)
- Recuperação de senha [#157](https://github.com/Openredu/Openredu/pull/157) [#222](https://github.com/Openredu/Openredu/pull/222)
- Visualizações [#152](https://github.com/Openredu/Openredu/pull/152)
- Busca com acentuação e nomes compostos [#142](https://github.com/Openredu/Openredu/pull/142)

### Remoções

- Alerta de navegador desatualizado [#210](https://github.com/Openredu/Openredu/pull/210)
- Scribd [#162](https://github.com/Openredu/Openredu/pull/162)
- Typekit [#158](https://github.com/Openredu/Openredu/pull/158)
- Flash e imagem do CKEditor [#155](https://github.com/Openredu/Openredu/pull/155) [#217](https://github.com/Openredu/Openredu/pull/217) [#218](https://github.com/Openredu/Openredu/pull/218)
- JWPlayer [#131](https://github.com/Openredu/Openredu/pull/131)

### Contribuições :heart:

|-|Commits|Arquivos modificados|Linhas adicionadas|Linhas removidas|
|-|-|-|-|-|
|Rafael Albuquerque|187|5009 | 507911 | 80890 |
|Bouckaert|90|177 | 1161 | 1253 |
|Ricardo Fagundes|51|128 | 663 | 287 |
|Heitor Carvalho|25|17 | 35 | 31 |
|Heitorado|21|54 | 1083 | 112 |
|Matheus Santana|12|259 | 12713 | 19787 |
|bjccin|8|11 | 32 | 26 |
|jenkinsopenredu|6|5 | 5 | 0 |
|AluisioPereira|4|10 | 10 | 9 |
|Heitor Sammuel Carvalho Souza|2|235 | 1736 | 1724 |
|Hugo Ramos Freire Neto|2|1 | 6 | 141 |
|Juliano Cezar Teles Vaz|2|5 | 23 | 12 |
|Yves Bouckaert|2|2 | 14 | 11 |
|Rafael Aquino|1|1 | 2 | 2 |

## [1.0.2] - 2017-03-22

Fim do ciclo de desenvolvimento de novas funcionalidades na versão 1.0.
Um novo branch (1.0.x) será criado apenas para fins de manutenção,
pois apenas backports serão incorporados ao código.

## [1.0.1] - 2011-09-23

Novo mural.

## [1.0.0] - 2011-05-21

CHANGELOG:
- Problemas do upload resolvidos (inclui IE)
- Migração para Rails 3.0.7
- Otimização de arquivos estáticos
- Otimização p/ o IE
- Configuração do ambiente de staging p/ imitar produção.

## [0.9.2] - 2011-05-02

CHANGELOG:
- Bugfix #202

## [0.9.1] - 2011-05-02

CHANGELOG:
- Remoção de views, controladores e models não utilizados
- Bugfixes: #273, #268, #271, #272, #275, #113

## [0.9.0] - 2011-04-29

CHANGELOG:
N/A

TODO para a versão 1.0.0
- Problemas relativos a upload (fron-end e back-end)

[Unreleased]: https://github.com/Openredu/Openredu/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/Openredu/Openredu/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Openredu/Openredu/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/Openredu/Openredu/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/Openredu/Openredu/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Openredu/Openredu/compare/v0.9.2...v1.0.0
[0.9.2]: https://github.com/Openredu/Openredu/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/Openredu/Openredu/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/Openredu/Openredu/releases/tag/v0.9.0
[#294]: https://github.com/Openredu/Openredu/pull/294
[#287]: https://github.com/Openredu/Openredu/pull/287
[#286]: https://github.com/Openredu/Openredu/pull/286
[#294]: https://github.com/Openredu/Openredu/pull/294
[#60]: https://github.com/Openredu/Openredu/pull/60
