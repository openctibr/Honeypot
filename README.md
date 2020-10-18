# Honeypot SETUP

Este script irá efetuar as seguintes configurações:
- Criação de usuario "opencti"
- Alteração da Porta de Serviço SSH de 22 para 2222
- Instalação do Tunel de VPN para comunicação com a Manager de Honeypot
- Instalação das Seguintes HoneyPot Sensors
- - Cowrie (HoneyPot para Detecção de Bruteforce de Autenticação SSH)
- - Dioneaa (HoneyPot para Captura de Samples de Malware)
- - Snort (HoneyPot para Captura de Tentativas de Exploração de Serviços)


# Instalação
- git clone https://github.com/openctibr/Honeypot.git
cd Honeypot
bash deployt.sh
