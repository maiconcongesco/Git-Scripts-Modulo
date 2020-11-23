#
#===========================================================================================#
#===========================================================================================#
#   Get Config - Extração de configs da apalicação instalada
#   Autor: Maicon Santos
#===========================================================================================#
#===========================================================================================#

<#==========================================================================================#
#   >>> OBSERVAÇÕES IMPORTANTES <<<
#===========================================================================================#
#===========================================================================================#
### Versões do Powershell e sua integração e compatibilidade com Windows e Windows Server ###
Powershell 1.0 — Foi feito para Windows XP SP2, Windows Server 2003 SP1 e Windows Vista. E é um componente opcional para Windows Server 2008.
Powershell 2.0 — Integrado com o Windows 7 e Windows Server 2008 R2. No Windows XP está disponível com o SP3, para o Windows Server 2003 com o SP2, e Windows Vista com o SP1.
Powershell 3.0 — Integrado com o Windows 8 e Windows Server 2012. No Windows 7, Windows Server 2008 e Windows Server 2008 R2 está disponível nos respectivos SP1.
Powershell 4.0 — Integrado com o Windows 8.1 e com o Windows Server 2012 R2. No Windows 7, Windows Server 2008 R2 e Windows Server 2012 está disponível nos respectivos SP1.
Powershell 5.0 — Integrado com o Windows Server 2016, 2019 e Windows 10 (no update de aniversário). A compatibilidade com o Windows Vista e Seven (7), Windows Server 2008, 2008 R2, 2012 e 2012 R2.
#===========================================================================================#
#===========================================================================================#
# Em algumas situações pode ser necessário alterar a diretiva de execução de script do Windows.
O cmdlet "Set-ExecutionPolicy" determina se os scripts PowerShell terão permissão de execução. O cmdlet "Get-ExecutionPolicy" verifica a política de execução corrente, o cmdlet aplica Set-ExecutionPolicy a política.
Set-ExecutionPolicy Restricted ### O PowerShell só pode ser usado no modo interativo. O script não poderá pode ser executado. 
Set-ExecutionPolicy Unrestricted ###  Todos os scripts do Windows PowerShell podem ser executados.
Set-ExecutionPolicy AllSigned ### Somente scripts assinados por um editor confiável podem ser executados.
Set-ExecutionPolicy RemoteSigned ### Os scripts baixados devem ser assinados por um editor confiável antes que possam ser executados.
#===========================================================================================#>

#===========================================================================================#
#   Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
#===========================================================================================#

# Geralmente essas váriaveis precisarão ser alteradas
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$DIRbkp = "D:\BackupRM" # Diretório de backup do Risk Manager
$VersionRM = "9.10.2.4" # Versão do RM que será arquivado (Backup)

# Ocasionalmente pode ser necessário alterar essas variáveis
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.

#===========================================================================================#>

# Liberação de execução de script
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#===========================================================================================#
#   Criando diretório para Backup de Configs
#===========================================================================================#
If(!(test-path "$DIRbkp\$VersionRM\Configs"))
{
      New-Item -ItemType Directory -Force -Path "$DIRbkp\$VersionRM\Configs"
}
#>

#===========================================================================================#
#===========================================================================================#
#   Extraindo Configs
#===========================================================================================#
#===========================================================================================#

# Copia os arquivos e a estrutura de Diretórios.
Copy-Item "$DIRsiteRM" -Filter "Web.config" -Destination "$DIRbkp\$VersionRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "RM.Service.exe.config" -Destination "$DIRbkp\$VersionRM\Configs\RiskManager" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "tenants.config" -Destination "$DIRbkp\$VersionRM\Configs\RiskManager" -Recurse -Force -Verbose
Copy-Item "$DIRsiteRM\RM" -Filter "modulelicenses*.config" -Destination "$DIRbkp\$VersionRM\LicenseRM" -Recurse -Force -Verbose

# Removendo os configs e estrutura de diretórios desnecessários.
Remove-Item -recurse $DIRbkp\$VersionRM\Configs\*\* -exclude *.config -Verbose

# Compactando Pasta com configs
Add-Type -Assembly "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory("$DIRbkp\$VersionRM\Configs\RiskManager", "$DIRbkp\$VersionRM\Configs.zip")

# Abrindo pasta
Set-Location "$DIRbkp\$VersionRM"
Start-Process .

#===========================================================================================#
#   ERRO EM REMOÇÃO DE LOGS? PODE SER APENAS UM ERRO ESPERADO.
#===========================================================================================#
# ATENÇÃO: Se o Serviço e os Application pools não estiverem parados os logs do dia NÃO serão removidos.
# Uma messagem de erro em vermelho aparecerá (...The process cannot access the file...because it is being used by another process...)
# Não se preocupe, apesar de parecer um erro não é, a aplicação precisa manter-se escrevendo esse log, esse "erro" é esperado.