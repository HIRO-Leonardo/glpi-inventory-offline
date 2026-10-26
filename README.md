# GLPI Inventory Offline & Automator

## Descricao do Projeto
Desenvolvimento de uma solucao de automacao em PowerShell para otimizar a implantacao do GLPI Agent e a coleta de inventario em estacoes de trabalho. O script automatiza a varredura do sistema, a remocao de agentes legados (como o FusionInventory), a instalacao silenciosa do novo software e a configuracao de regras de firewall. 

A ferramenta tambem executa o dump local estruturado do inventario de hardware e software em formato XML, salvando-o diretamente na Area de Trabalho do usuario, garantindo compatibilidade para importacao manual no sistema de gestao.

## Funcionalidades
* **Verificacao e Limpeza:** Identifica e desinstala versoes antigas do FusionInventory Agent silenciosamente.
* **Instalacao Automatizada:** Realiza o deploy do `GLPI-Agent-1.19-x64.msi` de forma transparente para o usuario.
* **Configuracao de Rede:** Aplica automaticamente regras de Firewall no Windows para permitir testes de Ping (ICMPv4).
* **Dump de Inventario Local:** Forca a geracao do inventario completo da maquina e salva o arquivo `.xml` devidamente formatado (UTF-8) na Area de Trabalho.

## Requisitos
* Sistema Operacional: Windows 10 ou superior.
* Permissoes: Necessario executar o script com privilegios de Administrador.
* Dependencias: O arquivo de instalacao `GLPI-Agent-1.19-x64.msi` deve estar no mesmo diretorio do script.

## Como Utilizar
1. Baixe os arquivos deste repositorio e coloque-os em uma mesma pasta (o script `.ps1` e o instalador `.msi`).
2. Clique com o botao direito no menu Iniciar do Windows e abra o **PowerShell (Administrador)**.
3. Navegue ate a pasta onde os arquivos foram salvos.
4. Execute o script digitando: `.\nome-do-script.ps1`
5. Aguarde a conclusao. Uma caixa de dialogo confirmara que o arquivo `NOME-DO-PC.xml` foi gerado na Area de Trabalho.
6. Importe o arquivo XML gerado diretamente na aba de inventario do seu servidor GLPI.

## Impacto do Projeto
Essa implementacao eliminou etapas manuais repetitivas, reduziu significativamente o tempo medio de configuracao por maquina e garantiu a padronizacao na atualizacao da base de dados do parque tecnologico, evitando erros de formatacao e dados inconsistentes.

---
**Autor:** Hiro-Leonardo
