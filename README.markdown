## Redu Core

Este repositório contem o core do Redu. O redu-core é a parte central da plataforma social educacional Redu. Também existem alguns subsistemas/serviços que estão em servidores/projetos/repositórios diferentes. A saber:

- [Portal de aplicativos](http://github.com/redu/apps): Marketplace de aplicativos educacionais.
- [Visualizações semânticas](http://github.com/redu/vis): Armazenamento e construção de visualizações semânticas do Redu.
- [Central de Ajuda](http://github.com/redu/help-center): [Tutoriais](http://ajuda.redu.com.br) de suporte no uso da plataforma.
- [Página de desenvolvedores](http://github.com/redu/redu.github.com): Documentação da API REST do Redu
- [Página da empresa](http://github.com/redu/tech.redu.com.br): Página do [Redu Educational Technologies](http://tech.redu.com.br)
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

Redu e a documentação do Redu são distribuídos na esperança de que eles vão ser útil, mas SEM NENHUMA GARANTIA; sem mesmo a garantia implícita de COMERCIALIZAÇÃO ou ADEQUAÇÃO A UM DETERMINADO FIM. Consulte a Licença Pública Geral GNU abaixo para mais detalhes.

```
GNU GENERAL PUBLIC LICENSE

Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.  
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.
Preamble

The licenses for most software are designed to take away your freedom to share and 
change it. By contrast, the GNU General Public License is intended to guarantee your 
freedom to share and change free software--to make sure the software is free for all 
its users. This General Public License applies to most of the Free Software Foundation's 
software and to any other program whose authors commit to using it. (Some other Free 
Software Foundation software is covered by the GNU Lesser General Public License instead.) 
You can apply it to your programs, too.

When we speak of free software, we are referring to freedom, not price. Our General Public 
Licenses are designed to make sure that you have the freedom to distribute copies of free
software (and charge for this service if you wish), that you receive source code or can get 
it if you want it, that you can change the software or use pieces of it in new free programs;
and that you know you can do these things.

To protect your rights, we need to make restrictions that forbid anyone to deny you these 
rights or to ask you to surrender the rights. These restrictions translate to certain 
responsibilities for you if you distribute copies of the software, or if you modify it.

For example, if you distribute copies of such a program, whether gratis or for a fee, you must
give the recipients all the rights that you have. You must make sure that they, too, receive
or can get the source code. And you must show them these terms so they know their rights.

We protect your rights with two steps: (1) copyright the software, and (2) offer you this license
which gives you legal permission to copy, distribute and/or modify the software.

Also, for each author's protection and ours, we want to make certain that everyone understands 
that there is no warranty for this free software. If the software is modified by someone else and 
passed on, we want its recipients to know that what they have is not the original, so that any 
problems introduced by others will not reflect on the original authors' reputations.

Finally, any free program is threatened constantly by software patents. We wish to avoid the danger
that redistributors of a free program will individually obtain patent licenses, in effect making 
the program proprietary. To prevent this, we have made it clear that any patent must be licensed
for everyone's free use or not licensed at all.

The precise terms and conditions for copying, distribution and modification follow.

TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. This License applies to any program or other work which contains a notice placed by the copyright
holder saying it may be distributed under the terms of this General Public License. The "Program",
below, refers to any such program or work, and a "work based on the Program" means either the Program
or any derivative work under copyright law: that is to say, a work containing the Program or a portion
of it, either verbatim or with modifications and/or translated into another language. (Hereinafter,
translation is included without limitation in the term "modification".) Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not covered by this License; they 
are outside its scope. The act of running the Program is not restricted, and the output from the 
Program is covered only if its contents constitute a work based on the Program (independent of having
been made by running the Program). Whether that is true depends on what the Program does.

1. You may copy and distribute verbatim copies of the Program's source code as you receive it, in any
medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright
notice and disclaimer of warranty; keep intact all the notices that refer to this License and to the 
absence of any warranty; and give any other recipients of the Program a copy of this License along 
with the Program.

You may charge a fee for the physical act of transferring a copy, and you may at your option offer 
warranty protection in exchange for a fee.

2. You may modify your copy or copies of the Program or any portion of it, thus forming a work based 
on the Program, and copy and distribute such modifications or work under the terms of Section 1 above, 
provided that you also meet all of these conditions:

a) You must cause the modified files to carry prominent notices stating that you changed the files and 
the date of any change.
b) You must cause any work that you distribute or publish, that in whole or in part contains or is derived
from the Program or any part thereof, to be licensed as a whole at no charge to all third parties under 
the terms of this License.
c) If the modified program normally reads commands interactively when run, you must cause it, when started 
running for such interactive use in the most ordinary way, to print or display an announcement including 
an appropriate copyright notice and a notice that there is no warranty (or else, saying that you provide
a warranty) and that users may redistribute the program under these conditions, and telling the user how
to view a copy of this License. (Exception: if the Program itself is interactive but does not normally 
print such an announcement, your work based on the Program is not required to print an announcement.)
These requirements apply to the modified work as a whole. If identifiable sections of that work are not 
derived from the Program, and can be reasonably considered independent and separate works in themselves, 
then this License, and its terms, do not apply to those sections when you distribute them as separate works.
But when you distribute the same sections as part of a whole which is a work based on the Program, the 
distribution of the whole must be on the terms of this License, whose permissions for other licensees 
extend to the entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest your rights to work written entirely
by you; rather, the intent is to exercise the right to control the distribution of derivative or collective
works based on the Program.

In addition, mere aggregation of another work not based on the Program with the Program (or with a work based
on the Program) on a volume of a storage or distribution medium does not bring the other work under the scope 
of this License.

3. You may copy and distribute the Program (or a work based on it, under Section 2) in object code or 
executable form under the terms of Sections 1 and 2 above provided that you also do one of the following:

a) Accompany it with the complete corresponding machine-readable source code, which must be distributed
under the terms of Sections 1 and 2 above on a medium customarily used for software interchange; or,
b) Accompany it with a written offer, valid for at least three years, to give any third party, for a charge
no more than your cost of physically performing source distribution, a complete machine-readable copy of
the corresponding source code, to be distributed under the terms of Sections 1 and 2 above on a medium 
customarily used for software interchange; or,
c) Accompany it with the information you received as to the offer to distribute corresponding source code.
(This alternative is allowed only for noncommercial distribution and only if you received the program in 
object code or executable form with such an offer, in accord with Subsection b above.)
The source code for a work means the preferred form of the work for making modifications to it. For an 
executable work, complete source code means all the source code for all modules it contains, plus any 
associated interface definition files, plus the scripts used to control compilation and installation of
the executable. However, as a special exception, the source code distributed need not include anything 
that is normally distributed (in either source or binary form) with the major components (compiler, kernel,
and so on) of the operating system on which the executable runs, unless that component itself accompanies
the executable.

If distribution of executable or object code is made by offering access to copy from a designated place,
then offering equivalent access to copy the source code from the same place counts as distribution of the
source code, even though third parties are not compelled to copy the source along with the object code.

4. You may not copy, modify, sublicense, or distribute the Program except as expressly provided under this
License. Any attempt otherwise to copy, modify, sublicense or distribute the Program is void, and will 
automatically terminate your rights under this License. However, parties who have received copies, or rights,
from you under this License will not have their licenses terminated so long as such parties remain in 
full compliance.

5. You are not required to accept this License, since you have not signed it. However, nothing else grants
you permission to modify or distribute the Program or its derivative works. These actions are prohibited by 
law if you do not accept this License. Therefore, by modifying or distributing the Program (or any work 
based on the Program), you indicate your acceptance of this License to do so, and all its terms and 
conditions for copying, distributing or modifying the Program or works based on it.

6. Each time you redistribute the Program (or any work based on the Program), the recipient automatically 
receives a license from the original licensor to copy, distribute or modify the Program subject to these 
terms and conditions. You may not impose any further restrictions on the recipients' exercise of the rights 
granted herein. You are not responsible for enforcing compliance by third parties to this License.

7. If, as a consequence of a court judgment or allegation of patent infringement or for any other reason 
(not limited to patent issues), conditions are imposed on you (whether by court order, agreement or otherwise)
that contradict the conditions of this License, they do not excuse you from the conditions of this License. 
If you cannot distribute so as to satisfy simultaneously your obligations under this License and any other 
pertinent obligations, then as a consequence you may not distribute the Program at all. For example, if a 
patent license would not permit royalty-free redistribution of the Program by all those who receive copies 
directly or indirectly through you, then the only way you could satisfy both it and this License would be
to refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under any particular circumstance, the balance
of the section is intended to apply and the section as a whole is intended to apply in other circumstances.

It is not the purpose of this section to induce you to infringe any patents or other property right claims or
to contest validity of any such claims; this section has the sole purpose of protecting the integrity of the 
free software distribution system, which is implemented by public license practices. Many people have made 
generous contributions to the wide range of software distributed through that system in reliance on consistent
application of that system; it is up to the author/donor to decide if he or she is willing to distribute 
software through any other system and a licensee cannot impose that choice.

This section is intended to make thoroughly clear what is believed to be a consequence of the rest of this License.

8. If the distribution and/or use of the Program is restricted in certain countries either by patents or by 
copyrighted interfaces, the original copyright holder who places the Program under this License may add an
explicit geographical distribution limitation excluding those countries, so that distribution is permitted
only in or among countries not thus excluded. In such case, this License incorporates the limitation as if 
written in the body of this License.

9. The Free Software Foundation may publish revised and/or new versions of the General Public License from 
time to time. Such new versions will be similar in spirit to the present version, but may differ in detail
to address new problems or concerns.

Each version is given a distinguishing version number. If the Program specifies a version number of this
License which applies to it and "any later version", you have the option of following the terms and conditions 
either of that version or of any later version published by the Free Software Foundation. If the Program does
not specify a version number of this License, you may choose any version ever published by the Free Software
Foundation.

10. If you wish to incorporate parts of the Program into other free programs whose distribution conditions 
are different, write to the author to ask for permission. For software which is copyrighted by the Free Software
Foundation, write to the Free Software Foundation; we sometimes make exceptions for this. Our decision will be
guided by the two goals of preserving the free status of all derivatives of our free software and of promoting 
the sharing and reuse of software generally.

NO WARRANTY

11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED
BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY 
AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL 
NECESSARY SERVICING, REPAIR OR CORRECTION.

12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER
PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING
ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM
(INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD 
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS 
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

END OF TERMS AND CONDITIONS

How to Apply These Terms to Your New Programs

If you develop a new program, and you want it to be of the greatest possible use to the public, the best way 
to achieve this is to make it free software which everyone can redistribute and change under these terms.

To do so, attach the following notices to the program. It is safest to attach them to the start of each source
file to most effectively convey the exclusion of warranty; and each file should have at least the "copyright" 
line and a pointer to where the full notice is found.

one line to give the program's name and an idea of what it does.
Copyright (C) yyyy  name of author

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this when it starts in an interactive mode:

Gnomovision version 69, Copyright (C) year name of author
Gnomovision comes with ABSOLUTELY NO WARRANTY; for details
type `show w'.  This is free software, and you are welcome
to redistribute it under certain conditions; type `show c' 
for details.
The hypothetical commands `show w' and `show c' should show the appropriate parts of the General Public License.
Of course, the commands you use may be called something other than `show w' and `show c'; they could even be
mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your school, if any, to sign a "copyright
disclaimer" for the program, if necessary. Here is a sample; alter the names:

Yoyodyne, Inc., hereby disclaims all copyright
interest in the program `Gnomovision'
(which makes passes at compilers) written 
by James Hacker.

signature of Ty Coon, 1 April 1989
Ty Coon, President of Vice
This General Public License does not permit incorporating your program into proprietary programs. If your program
is a subroutine library, you may consider it more useful to permit linking proprietary applications with the 
library. If this is what you want to do, use the GNU Lesser General Public License instead of this License.
```
