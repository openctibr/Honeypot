# Honeypot OpenCTI.BR

# Requisitos de Hardware
- Ubuntu Linux 64bits (amd64) 16.04
- 1 vCPU
- 1 GB RAM
- 30 GB Disco

# Recomendações de Deploy do Hardware
- AWS Free Tier: 
  - Region: South America - São Paulo
  - Instance Type t2.micro
  - AMI: ami-041fa5e7959ae4b04 (Ubuntu Server 16.04 LTS (HVM), SSD Volume Type)
- OpenCTI.BR OVA: Disponível em (BREVE)

# Requisitos de Rede
- A porta de Acesso Remoto (SSH) será alterada para 2222/TCP, portanto esta porta você deverá configurar com as restrições de acesso de sua escolha.
- TODAS AS OUTRAS PORTAS TCP e UDP deverão estar liberadas de forma IRRESTRITA para que os sensores possam coletar o máximo possível de informações.

# Instalação
- git clone https://github.com/openctibr/Honeypot.git
- cd Honeypot
- bash deploy.sh

# OBSERVAÇÕES
Este script irá efetuar as seguintes configurações:
- Criação de usuario "opencti"
- Alteração da Porta de Serviço SSH de 22 para 2222
- Instalação do Tunel de VPN para comunicação com a Manager de Honeypot
- Instalação das Seguintes HoneyPot Sensors
  - Cowrie (HoneyPot para Detecção de Bruteforce de Autenticação SSH)
  - Dioneaa (HoneyPot para Captura de Samples de Malware)
  - Snort (HoneyPot para Captura de Tentativas de Exploração de Serviços)
