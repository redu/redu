## OpenRedu Core

Este repositório contem o core do OpenRedu. O openredu-core é a parte central da plataforma social educacional OpenRedu. Também existem alguns subsistemas/serviços que estão em servidores/projetos/repositórios diferentes. A saber:

- [Portal de aplicativos](http://github.com/redu/apps): Marketplace de aplicativos educacionais.
- [Visualizações semânticas](http://github.com/redu/vis): Armazenamento e construção de visualizações semânticas do Redu.
- [Central de Ajuda](http://github.com/OpenRedu/help-center): [Tutoriais](http://ajuda.openredu.com) de suporte no uso da plataforma.
- [Página de desenvolvedores](http://github.com/redu/redu.github.com): Documentação da API REST do Redu
- [Página do livro](http://github.com/redu/livro): Pagina do livro [Educar com o Redu](http://educarcom.redu.com.br)
- [Redu Mobile](http://github.com/redu/mobile): Aplicativo Android oficial.
- [Wally Server](http://github.com/redu/wally): Mural do Redu (server-side)
- [Wally.js](http://github.com/redu/wally.js): Mural do Redu (client-side)
- [Untied](http://github.com/redu/untied): Message Bus utilizado na comunicação entre serviços.
- [Permit](http://github.com/redu/permit): Autorização e gerênciamento de políticas de acesso entre serviços.
- [ReduPy](http://github.com/redu/redupy): Encapsulador Python para a API REST do Redu.
- [JRedu](http://github.com/redu/jredu): Encapsulador Java para a API REST do Redu

### Setup

Checkout do código:

```sh
$ > git clone git@github.com:redu/redu.git
$ > cd redu
$ redu > bundle install --binstubs
```

Inicialização do MySQL e MongoDB

```sh
$ redu > mysqld_safe
121212 08:45:50 mysqld_safe Logging to '/usr/local/mysql/data/scissorhands.local.err'.
121212 08:45:50 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/data
```

```sh
$ redu > mongod --journal
redu (master) > mongod --dbpath=$HOME/usr/data/   --journal
Wed Dec 12 08:48:20 [initandlisten] MongoDB starting : pid=4144 port=27017 dbpath=/Users/guiocavalcanti/usr/data/ 32-bit host=scissorhands.local
Wed Dec 12 08:48:21 [initandlisten] waiting for connections on port 27017
```

Criação dos bancos e esquema:

```sh
$ redu > bundle exec rake db:create
$ redu > bundle exec rake db:schema:load
```

Inserção de dados mandatórios:

```sh
$ redu > bundle exec rake bootstrap:all
```

Inicialização do servidor de busca:

```sh
$ redu > bundle exec rake sunspot:solr:start
```

Indexação dos modelos:

```sh
$ redu > bundle exec rake sunspot:solr:reindex
```

Inicialização do servidor de desenvolvimento:

```sh
$ redu > bundle exec rails server
```

Para mais informações sobre o setup, consultar [este](https://github.com/redu/redu/wiki/Redu-Setup) guia.

#### Dependências

Para fazer o Redu funcionar em ambiente de desenvolvimento você precisará instalar as seguintes dependências:

- MySQL 5.1
- MongoDB 2.0.6
- Solr 1.4.0

### Coding style

O estilo e padrões de código utilizados estão disponíveis [neste](https://github.com/redu/redu/wiki/Coding-Patterns) guia. Leia com atenção antes de submeter patches.

### Contribuições

#### Pull requests

Os passos para contribuir com a evolução do código, seja para resolução de issue ou criação de features são os seguintes:

1. Criar um branch novo
2. Realizar mudanças ou adicionar a feature
3. Commitar mudanças e enviá-las para o remoto
4. Realizar pull request e atribuir a um revisor
5. Caso existam revisões: realizar novos commits no mesmo branch criado e enviar para o remoto

Um exemplo de resolução de issue seguiria o seguinte fluxo:

Assumindo que o issue tenha o ID 1300.

```sh
$ redu (master) > git pull origin master
$ redu (master) > git checkout -b issue-1300
$ redu (issue-1300) > git commit -a -m "Minhas modificações"
$ redu (issue-1300) > git push origin issue-1300
```

Para mais informações sobre como fazer o pull request, consulte [este](https://help.github.com/articles/using-pull-requests) post.

#### Reportando issues da API

O primeiro passo é decidir em qual repositório criar o issue:

- Para bugs na API HTTP propriamente dita: https://github.com/redu/redu/issues
- Para bugs na documentação: https://github.com/redu/redu.github.com/issues
- Para bugs no encapsulador Java: https://github.com/redu/jredu/issues
- Para bugs no encapsulador Python: https://github.com/redu/redupy/issues

Para problemas na API REST, É importante expressar os problemas em termos de HTTP e não da linguagem utilizada. Por exemplo, ao invés de dizer que o método ``getUsers()`` está lançando null pointer, tentem explicar que uma requisição do tipo GET para ``/api/spaces/1/users`` está retornando o código 500. Fica mais fácil de investigar dessa forma.

### DelayedJob

O [DelayedJob](https://github.com/collectiveidea/delayed_job) é utilizado como infraestrutura para processamento de tarefas em background.

Para reinicializar o DelayedJob, em produção, use ``monit restart``. Por exemplo:

```sh
$ > sudo monit restart delayed_job.0
$ > sudo monit restart delayed_job.1
$ > sudo monit restart delayed_job.2
$ > sudo monit restart delayed_job.3
```

#### Responsabilidades de cada worker do Delayed Job

- `delayed_job.0` (general): Execução de tarefas gerais como criação de associações entre usuários e postagens no mural (não há necessidade de serem executadas imediatamente).
- `delayed_job.1` (email): Envio de emails.
- `delayed_job.2` (vis): Envio de dados para Vis (requisições HTTP).
- `delayed_job.3` (hierarchy-associations): Criação de associações da hierarquia que precisam ser feitas o quanto antes.

### Serviço de entrega de e-mails

Nossos e-mails são entregues pelo [Amazon SES](http://aws.amazon.com/ses/). Como a entrega de e-mails é uma tarefa excessivamente bloqueante, isso é feito em segundo plano pelo [DelayedJob](https://github.com/collectiveidea/delayed_job#rails-3-mailers).

Para utilizar entrega em segundo plano, é necessário chamar o método do ActionMailer da seguinte forma: ``object.delay(:queue => 'email').method``. Onde ``method`` é tipo de notificação que deve ser gerada. Por exemplo, para enviar o e-mail de convite, a chamada seria a seguinte:

```ruby
UserNotifier.delay(:queue => 'email').external_user_course_invitation(user_course_invitation, course)
```

É importante notar que e-mails devem ser enfileirados na fila ``email`` para evitar que o envio dos mesmos afetem a vazão do processamento de outros Jobs. Para cada e-mail será enfileirado um Job do DelayedJob que lidará com a renderização da View e entrega para a Amazon SES.


Para mais informações de uso: ``bundle exec ar_sendmail_rails3 -h``

### Deploy

O Redu (http://www.redu.com.br) funciona na infraestrutura da [Amazon](http://aws.amazon.com/) através do [EngineYard](http://www.engineyard.com/). Assumindo que você possua as permissões necessárias, para realizar o deploy basta executar o seguinte comando:

```
$ > ey deploy -a redu -r master --migrate
```

#### Gems em repositórios privados

Existem duas formas de utilizar Gems privados no Redu:

A primeira é colocá-lo em um repositório privado e dar acesso ao usuário [tiago-redu](http://github.com/tiago-redu). Este usuário possui as credenciais da instância ``app_master``.

A segunda é utilizar o servidor de Gem privado [The Shire](http://github.com/redu/the-shire).


#### SSH

Para realizar login na instância do Redu via SSH basta executar o seguinte comando:

```sh
$ > ey ssh -e production

```

Ou simplesmente faça login através do SSH:

```sh
$ > ssh deploy@redu.com.br
```

#### Monitoramento de processos

Em produção utilizamos o [Monit](http://mmonit.com/monit/) para monitorar processos. Para saber quais processos são monitorados e seus estados use a opção ``summary``:

```sh
$ sudo monit summary
The Monit daemon 5.0.3 uptime: 7d 22h 12m

Process 'solr_redu_9080'            running
Process 'rabbitmq_ssh_tunnel'       running
Process 'nrsysmond'                 running
Process 'mongo_ssh_tunnel'          running
Process 'mini_httpd'                running
Process 'delayed_job.3'             running
Process 'delayed_job.2'             running
Process 'delayed_job.1'             running
Process 'delayed_job.0'             running
System 'domU-12-31-39-09-9C-54'     running
```

Para mais informações sobre como utilizar o monit, execute ``sudo monit -h``.

#### nginx

Em produção o Redu funciona através do [Passenger](http://www.modrails.com/documentation/Users%20guide%20Nginx.html) (com o nginx). Para reiniciar o servidor basta reinicializar o serviço nginx:

```sh
$ > /etc/init.d/niginx restart
```

#### Cache

Utilizamos o [Memcached](http://memcached.org/) como sistema de *caching*, o [setup](https://support.cloud.engineyard.com/entries/22375358-Using-Memcached-on-Engine-Yard-Cloud) é feito por default pelo Engine Yard (ambiente em *cluster*). Nós apenas configuramos para usar o cliente [Dalli](https://github.com/mperham/dalli) em produção.

# Espaço utilizado

Para ver todo o espaço utilizado nas intâncias use o seguinte comando:
`sudo du -H --max-depth=1 .`

# Licença Utilizada

O pacote global de software Redu tem direitos reservados para vários autores registrado junto ao INPI. Ele é um Software Livre e de Código Aberto e tudo isso é fornecido sob os termos da licença [GNU General Public License versão 2](http://www.gnu.org/licenses/gpl-2.0.html) publicada pela [Free Software Foundation](http://www.fsf.org/).

Redu e a documentação do Redu são distribuídos na esperança de que eles vão ser útil, mas SEM NENHUMA GARANTIA; sem mesmo a garantia implícita de COMERCIALIZAÇÃO ou ADEQUAÇÃO A UM DETERMINADO FIM. Consulte a Licença Pública Geral GNU [aqui] para mais detalhes.

[aqui]: https://github.com/OpenRedu/OpenRedu/blob/master/LICENSE
