##
<#===========================================================================================#
#===========================================================================================#
#
#   Atualização Risk Manager
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/UpdateRM.ps1
#
#===========================================================================================#
#===========================================================================================#>

#===========================================================================================#
#   Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
#===========================================================================================#

# Normalmente é necessário alterar essas variáveis
$VersionRM = "9.10.2.11" # Versão do RM que será instalada
$VersionBKPRM = "9.10.2.7" # Versão do RM que será arquivado (Backup)
$DIRbkp = "D:\BackupRM" # Diretório de backup do Risk Manager
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$RaizInstall = "D:\FilesRiskManager" # Diretório onde se encontrará a pasta do pacote de instalação depois de descompactado

# Ocasionalmente pode ser necessário alterar essas variáveis
$NameSite = "RiskManager" # Nome do Site do Risk Manager no IIS
$FileManual = "$RaizInstall\Manual_RM_9.10_pt_br.zip" # Caminho do Manual compactado.
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
$ModuloSchedulerService = "ModuloSchedulerService" # Execute o comando [Get-Service -Name "Modulo*", "Risk*" | ft -Autosize] sem os "[]" para descobrir o Nome do Serviço do Modulo Scheduler
$RiskManagerService =  "RiskManagerService" # Execute o comando [Get-Service -Name "Modulo*", "Risk*" | ft -Autosize] sem os "[]" para descobrir o Nome do Serviço do Modulo Scheduler
$ConfigRM = "$DIRbkp\$VersionBKPRM\Configs.zip" # Configs editados e disponibilizados na estrutura correta de pastas para o Risk Manager

# Raramente será necessário alterar essas variáveis
$PackInstallRM = "$RaizInstall\RM_$VersionRM" # Diretório descompactado dos arquivos de instalação do Risk Manager
$PackRMZIP = "$RaizInstall\RM_$VersionRM.zip" # Caminho com o pacote de intalação compactado do Risk Manager
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos que serão deletados.
$LogPath = "$DIRsvcRM", "$DIRsvcScheduler", "$DIRsiteRM"   # Caminho da pasta principal onde iremos buscar e limpar os logs, Separe por virgula se for mais de uma pasta.

<#==========================================================================================#
#   >>> OBSERVAÇÕES IMPORTANTES <<<
#===========================================================================================#
#   Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools"
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
#===========================================================================================#
#===========================================================================================#>

# Inicio da execução do Script
$command = Get-History -Count 1 # Vai Cronometrar o tempo que o script levará em execução
$command.StartExecutionTime 

# Versão do PowerShell
$PSVersionTable

<#===========================================================================================#>
<# Verificando se os Recursos do Windows requeridos estão instalados
<#===========================================================================================#>
# Get-WindowsFeature -Name web-server, web-webserver,  web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45 | Select-Object Name , InstallState

<#===========================================================================================#>
<#  Instalando os Recursos Windows		         				
<#===========================================================================================#>
# Add-WindowsFeature web-server, web-webserver, web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45

<#===========================================================================================#>
<#  Desbloqueando arquivos baixados da internet
<#===========================================================================================#>
Unblock-File -Path "$RaizInstall\*"

<#===========================================================================================#>
<#  Descompactando o pacote de "Tools"
<#===========================================================================================#>
# Expand-Archive -Path "$RaizInstall\Tools.zip" -DestinationPath "$RaizInstall" -Verbose

#===========================================================================================#
#   Descompactando os arquivos das aplicações do Risk Manager
#===========================================================================================#
Expand-Archive -Path "$PackRMZIP" -DestinationPath "$RaizInstall" -Verbose

#===========================================================================================#
#   Parando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "$ModuloSchedulerService", "$RiskManagerService" | Stop-Service

#===========================================================================================#
#   Verificando status dos serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "$ModuloSchedulerService", "$RiskManagerService" 

<#===========================================================================================#
#    Removendo os serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
# Remove-Service -Name "ServiceName" # Esse cmdlet foi introduzido no PowerShell 6.0
# (Get-WmiObject Win32_Service -filter "name='ServiceName'").Delete() # Esse é o cmdlet que funciona no PowerShell 5

sc.exe delete "$RiskManagerService"
sc.exe delete "$ModuloSchedulerService"
#>

#===========================================================================================#
#   Parando os WebAppPools
#===========================================================================================#
Stop-WebAppPool "RiskManager"
Stop-WebAppPool "RM"
Stop-WebAppPool "WF"
Stop-WebAppPool "DataAnalyticsCacher"
Stop-WebAppPool "DataAnalyticsService"
Stop-WebAppPool "DataAnalyticsUI"
Stop-WebAppPool "MMI"

# === Parando o PORTAL ou RM_PORTAL === #
if(Test-Path IIS:\AppPools\PORTAL)
{
"Parando PORTAL"
Stop-WebAppPool "PORTAL"
return $true;
}
else
{
"PORTAL não existe"
if(Test-Path IIS:\AppPools\RM_PORTAL)
{
"Parando RM_PORTAL"
Stop-WebAppPool "RM_PORTAL"
return $true;
}
else
{
"RM_PORTAL não existe"
return $false;
}
return $false;
}

# === Parando o BCM === #
if(Test-Path IIS:\AppPools\BCM)
{
"Parando BCM"
Stop-WebAppPool "BCM"
return $true;
}
else
{
"BCM não existe"
return $false;
}

# === Parando o ETLProcessor === #
if(Test-Path IIS:\AppPools\ETLProcessor)
{
"Parando ETLProcessor"
Stop-WebAppPool "ETLProcessor"
return $true;
}
else
{
"ETLProcessor não existe"
return $false;
}
#>

#===========================================================================================#
#   Verificando status dos WebAppPools
#===========================================================================================#
# Listando WebAppPools ativos
Get-IISAppPool | Where {$_.State -eq "Started"}
write-host "========" -ForegroundColor "DarkRed" -BackgroundColor white
# Listando WebAppPools parados
Get-IISAppPool | Where {$_.State -eq "Stopped"}

#===========================================================================================#
#	Limpando os Logs		>>> ATENÇÃO! Essa remoção pode ser irreversível
#===========================================================================================#
$Files = Get-Childitem $LogPath -Include $Extensions -Recurse | Where-Object {$_.LastWriteTime -le `
(Get-Date).AddDays(-$XDays)}

foreach ($File in $Files) 
{
    if ($NULL -ne $File)
      {
        write-host "Deletando arquivo $File" -ForegroundColor "DarkRed" -BackgroundColor "white"
        Remove-Item $File.FullName | out-null
      }
}

#===========================================================================================#
#   Criando o diretório de Backup
#===========================================================================================#
If(!(test-path $DIRbkp\$VersionBKPRM))
{
      New-Item -ItemType Directory -Force -Path $DIRbkp\$VersionBKPRM
}
#>

#===========================================================================================#
#   Criando diretório para Backup de Configs
#===========================================================================================#
If(!(test-path "$DIRbkp\$VersionBKPRM\Configs"))
{
      New-Item -ItemType Directory -Force -Path "$DIRbkp\$VersionBKPRM\Configs"
}
#>

#===========================================================================================#
#   Backup dos Configs do Risk Manager
#===========================================================================================#

# Copia os arquivos e a estrutura de Diretórios.
Copy-Item "$DIRsiteRM" -Filter "Web.config" -Destination "$DIRbkp\$VersionBKPRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "RM.Service.exe.config" -Destination "$DIRbkp\$VersionBKPRM\Configs\RiskManager" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "tenants.config" -Destination "$DIRbkp\$VersionBKPRM\Configs\RiskManager" -Recurse -Force -Verbose

# Removendo os configs e estrutura de diretórios desnecessários.
Remove-Item -recurse $DIRbkp\$VersionBKPRM\Configs\*\* -exclude *.config -Verbose

#===========================================================================================#
#   Criando diretório para Backup do arquivo de licença
#===========================================================================================#
If(!(test-path "$DIRbkp\$VersionBKPRM\LicenseRM"))
{
      New-Item -ItemType Directory -Force -Path "$DIRbkp\$VersionBKPRM\Configs\RiskManager\LicenseRM"
}
#>

#===========================================================================================#
#   Backup do arquivo de licença do Risk Manager
#===========================================================================================#
Copy-Item "$DIRsiteRM\RM\modulelicenses.config" -Destination "$DIRbkp\$VersionBKPRM\Configs\RiskManager\LicenseRM\modulelicenses.config" -Recurse -Force -Verbose

#===========================================================================================#
# Compactando Pasta com configs
#===========================================================================================#
Add-Type -Assembly "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory("$DIRbkp\$VersionBKPRM\Configs\RiskManager", "$DIRbkp\$VersionBKPRM\Configs.zip")

#===========================================================================================#
#   Fazendo o Backup dos Serviços RiskManager e Modulo Scheduler
#===========================================================================================#
Move-item "$DIRsvcRM" "$DIRbkp\$VersionBKPRM" -Verbose -Force # Backup do Serviço do RiskManager
Move-item "$DIRsvcScheduler" "$DIRbkp\$VersionBKPRM" -Verbose -Force # Backup do Serviço do Modulo Scheduler
#>

#===========================================================================================#
#   Criando diretório para Backup do Site RiskManager
#===========================================================================================#
If(!(test-path "$DIRbkp\$VersionBKPRM\$NameSite"))
{
      New-Item -ItemType Directory -Force -Path "$DIRbkp\$VersionBKPRM\$NameSite"
}
#>

#===========================================================================================#
#   Fazendo o Backup do Site RiskManager (Movendo arquivos)
#===========================================================================================#
Move-item -Path "$DIRsiteRM\*" "$DIRbkp\$VersionBKPRM\$NameSite" -Verbose -Force # Backup das Aplicações do Risk Manager
#>

#===========================================================================================#
#   Fazendo o Backup do RiskManager (Copiando arquivos) Removendo arquivos já arquivados
#===========================================================================================#
# copy-item $DIRsvcRM "$DIRbkp\$VersionBKPRM" -Recurse -Verbose # Backup do Serviço do RiskManager
# copy-item $DIRsvcScheduler "$DIRbkp\$VersionBKPRM" -Recurse -Verbose # Backup do Serviço do Modulo Scheduler
# copy-item $DIRsiteRM "$DIRbkp\$VersionBKPRM" -Recurse -Verbose # Backup das Aplicações do Risk Manager
# Remove-Item -Path $DIRsvcRM\* -Recurse -Verbose -Force
# Remove-Item -Path $DIRsvcScheduler\* -Recurse -Verbose -Force
# Remove-Item -Path $DIRsiteRM\* -Recurse -Verbose -Force
#>

#===========================================================================================#
#   Renomeando os arquivos dos serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
rename-item -path "$PackInstallRM\Binaries\Modulo Scheduler Service.zipx" -newname "Modulo Scheduler Service.zip" -Verbose
rename-item -path "$PackInstallRM\Binaries\RiskManager.Service.zipx" -newname "RiskManager.Service.zip" -Verbose
#>

#===========================================================================================#
#   Descompactando os arquivos dos serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
Expand-Archive -Path "$PackInstallRM\Binaries\Modulo Scheduler Service.zip" -DestinationPath $DIRsvcScheduler -Verbose
Expand-Archive -Path "$PackInstallRM\Binaries\RiskManager.Service.zip" -DestinationPath $DIRsvcRM -Verbose
#>

<#===========================================================================================#
#    Recriando os serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
New-Service -BinaryPathName $DIRsvcRM/RM.Service.exe -Name RiskManagerService -Description "Risk Manager Background Service Host" -DisplayName "Risk Manager Service" -Verbose
New-Service -BinaryPathName $DIRsvcScheduler/Modulo.Scheduler.Host.exe -Name ModuloSchedulerService -Description "Modulo Scheduler Background Service Host" -DisplayName "Modulo Scheduler Service" -Verbose
#>

#===========================================================================================#
#    Realizando o Deploy das aplicações web
#===========================================================================================#
# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"

# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/RM"

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Workflow.Services.Web.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/WF"

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/PORTAL"

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsCacher"

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsService" 

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsUI"

# Deploy da aplicação Data MMI 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\MMI\packages\Modulo.SICC.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/MMI" 

#>

#===========================================================================================#
#   Copiando a biblioteca DevExpress para Apps/bin
#===========================================================================================#
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\WF\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\PORTAL\bin" -Force -Verbose

#===========================================================================================#
#   Copiando o arquivo Modulo.RiskManager.DataAnalytics.Bootstrap
#===========================================================================================#
Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\Modulo.RiskManager.DataAnalytics.Bootstrap.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

#===========================================================================================#
#   Copiando o conteúdo da pasta do pacote Data Analytics\DashboardDesignerInstallers
#===========================================================================================#
Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\DashboardDesignerInstallers\*" -Destination "$DIRsiteRM\DataAnalyticsUI\Files" -Force -Verbose

#===========================================================================================#
#   Copiando os arquivos bin do MMI para o RM
#===========================================================================================#
Copy-Item -Path "$PackInstallRM\Web.Applications\MMI\bin\rm\*" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

#===========================================================================================#
#   Criando o diretório para o Manual
#===========================================================================================#
If(!(test-path $DIRsiteRM\RM\Manual\pt))
{
      New-Item -ItemType Directory -Force -Path $DIRsiteRM\RM\Manual\pt -Verbose
}
#>

#===========================================================================================#
#   Extraindo o Manual do Risk Manager para o App RM
#===========================================================================================#
Expand-Archive -Path "$FileManual" -DestinationPath "$DIRsiteRM\RM\Manual\pt" -Verbose
#>

#===========================================================================================#
#   Atualização dos arquivos de config a partir de um pacote de configs
#===========================================================================================#
Expand-Archive -Path "$ConfigRM" -DestinationPath "$DIRsiteRM" -Force -Verbose
Copy-Item -Path "$DIRsiteRM/RiskManager.Service/*.config" -Destination "$DIRsvcRM" -Force -Verbose
Remove-Item -Path "$DIRsiteRM/RiskManager.Service/" -Force -Recurse -Verbose
#>

#===========================================================================================#
#   Atualização do arquivo de licença
#===========================================================================================#
Copy-Item -Path "$DIRsiteRM/LicenseRM/modulelicenses.config"  -Destination "$DIRsiteRM\RM" -Force -Verbose
Remove-Item -Path "$DIRsiteRM/LicenseRM/" -Force -Recurse -Verbose
#>

#===========================================================================================#
#   Aplicando permissões para Network Service nos diretórios, subdiretórios e arquivos
#===========================================================================================#
icacls "$DIRsiteRM" /grant NetworkService:"(OI)(CI)F"
icacls "$DIRsvcRM" /grant NetworkService:"(OI)(CI)F"
icacls "$DIRsvcScheduler" /grant NetworkService:"(OI)(CI)F"
#>

#===========================================================================================#
#   Iniciando os WebAppPool
#===========================================================================================# 
Start-WebAppPool "RiskManager"
Start-WebAppPool "RM"
Start-WebAppPool "PORTAL"
Start-WebAppPool "WF"
Start-WebAppPool "DataAnalyticsCacher"
Start-WebAppPool "DataAnalyticsService"
Start-WebAppPool "DataAnalyticsUI"
Start-WebAppPool "MMI"

# === Iniciando o PORTAL ou RM_PORTAL === #
if(Test-Path IIS:\AppPools\PORTAL)
{
"Iniciando PORTAL"
Start-WebAppPool "PORTAL"
return $true;
}
else
{
"PORTAL não existe"
if(Test-Path IIS:\AppPools\RM_PORTAL)
{
"Iniciando RM_PORTAL"
Start-WebAppPool "RM_PORTAL"
return $true;
}
else
{
"RM_PORTAL não existe"
return $false;
}
return $false;
}

# === Iniciando o BCM === #
if(Test-Path IIS:\AppPools\BCM)
{
"Iniciando BCM"
Start-WebAppPool "BCM"
return $true;
}
else
{
"BCM não existe"
return $false;
}

# === Iniciando o ETLProcessor === #
if(Test-Path IIS:\AppPools\ETLProcessor)
{
"Iniciando ETLProcessor"
Start-WebAppPool "ETLProcessor"
return $true;
}
else
{
"ETLProcessor não existe"
return $false;
}
#>

#===========================================================================================#
#   Verifcando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "Modulo*", "Risk*"
#>

<#===========================================================================================#
#   Parando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "RiskManagerService" | Stop-Service
Get-Service -Name "ModuloSchedulerService" | Stop-Service
#>

<#===========================================================================================#
#   Iniciando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "RiskManagerService" | Start-Service
Get-Service -Name "ModuloSchedulerService" | Start-Service
#>


Write-Output "Inicio da execução do Script" 

$command.StartExecutionTime



Write-Output "Fim da execução do Script" 

Get-Date