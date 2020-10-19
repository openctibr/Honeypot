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
  - Security Group: *FULL ACCESS*
- Oracle OCI Free Tier:
  - Region: Brazil East - São Paulo
  - Instance Type: VM.Standard.E2.1.Micro
  - Image: Canonical Ubuntu 16.04
  - Use network security groups to control traffic: No
- OpenCTI.BR OVA: Disponível em https://www.dropbox.com/s/kgc1lmwcjfrpilj/OpenCTIBR_HoneyPot_Sensor_v1.OVA?dl=1

# Requisitos de Rede
- A porta de Acesso Remoto (SSH) será alterada para 2222/TCP, portanto esta porta você deverá configurar com as restrições de acesso de sua escolha.
- TODAS AS OUTRAS PORTAS TCP e UDP deverão estar liberadas de forma IRRESTRITA para que os sensores possam coletar o máximo possível de informações.

# Instalação
- apt install -y git
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
