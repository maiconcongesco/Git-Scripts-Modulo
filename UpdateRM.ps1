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
$PORTAL = "PORTAL" # Indica se o portal foi criado com o nome "RM_PORTAL" ou "PORTAL"
$BCM = "BCM" # Indica se o modulo Continuidade foi criado com o nome "BCM" ou "GCN"
$ModuloSchedulerService = "ModuloSchedulerService" # Nome do Serviço do Modulo Scheduler  - Execute para descobrir [Get-Service -Name "Modulo*" | ft -Autosize]
$RiskManagerService =  "RiskManagerService" # Nome do Serviço do Risk Manager - Execute para descobrir [Get-Service -Name "Risk*" | ft -Autosize]
$ConfigRM = "$DIRbkp\$VersionBKPRM\Configs.zip" # Configs editados e disponibilizados na estrutura correta de pastas para o Risk Manager

# Raramente será necessário alterar essas variáveis
$Tools = "B:\OneDrive\- Modulo\- Risk Manager\Tools\Tools2.0"
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos que serão deletados.
$LogPath = "$DIRsvcRM", "$DIRsvcScheduler", "$DIRsiteRM" # Caminho da pasta onde iremos buscar e limpar os logs, separe por virgula se for mais de uma pasta.

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
Powershell 5.0 — Integrado com o Windows Server 2016, 2019 e Windows 10 (no update de aniversário). Compatível com todos os Windows a partir do Vista e Windows Server 2008.
#===========================================================================================#
#===========================================================================================#
# Em algumas situações pode ser necessário alterar a diretiva de execução de script do Windows.
O cmdlet "Get-ExecutionPolicy" verifica a política de execução corrente.
O cmdlet "Set-ExecutionPolicy" determina se os scripts PowerShell terão permissão de execução. 
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
<# Validando diretórios e arquivos
<#===========================================================================================#>
test-path $DIRsiteRM
test-path $RaizInstall
test-path $RaizInstall\RM_$VersionRM.zip
test-path $FileManual
test-path $DIRsvcRM 
test-path $DIRsvcScheduler
#>

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
Expand-Archive -Path "$RaizInstall\RM_$VersionRM.zip" -DestinationPath "$RaizInstall" -Verbose

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
Stop-WebAppPool "$PORTAL"
Stop-WebAppPool "WF"
Stop-WebAppPool "DataAnalyticsCacher"
Stop-WebAppPool "DataAnalyticsService"
Stop-WebAppPool "DataAnalyticsUI"
Stop-WebAppPool "MMI"

# === Parando o BCM/GCN === #
if(Test-Path IIS:\AppPools\$BCM)
{
"Parando BCM"
Stop-WebAppPool "$BCM"
return $true;
}
else
{
"BCM/GCN não existe"
return $false;
}

#===========================================================================================#
#   Verificando status dos WebAppPools
#===========================================================================================#
# Listando WebAppPools ativos
Get-IISAppPool | Where-Object {$_.State -eq "Started"}
write-host "========" -ForegroundColor "DarkRed" -BackgroundColor white
# Listando WebAppPools parados
Get-IISAppPool | Where-Object {$_.State -eq "Stopped"}

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
#>

#===========================================================================================#
#   Criando diretório para Backup de Configs
#===========================================================================================#
If(!(test-path $DIRbkp\$VersionBKPRM\Configs))
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
If(!(test-path "$DIRbkp\$VersionBKPRM\Configs\RiskManager\LicenseRM"))
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
rename-item -path "$RaizInstall\RM_$VersionRM\Binaries\Modulo Scheduler Service.zipx" -newname "Modulo Scheduler Service.zip" -Verbose
rename-item -path "$RaizInstall\RM_$VersionRM\Binaries\RiskManager.Service.zipx" -newname "RiskManager.Service.zip" -Verbose
#>

#===========================================================================================#
#   Descompactando os arquivos dos serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
Expand-Archive -Path "$RaizInstall\RM_$VersionRM\Binaries\Modulo Scheduler Service.zip" -DestinationPath $DIRsvcScheduler -Verbose
Expand-Archive -Path "$RaizInstall\RM_$VersionRM\Binaries\RiskManager.Service.zip" -DestinationPath $DIRsvcRM -Verbose
#>

<#===========================================================================================#
#    Recriando os serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
New-Service -BinaryPathName $DIRsvcRM/RM.Service.exe -Name RiskManagerService -Description "Risk Manager Background Service Host" -DisplayName "Risk Manager Service" -Verbose
New-Service -BinaryPathName $DIRsvcScheduler/Modulo.Scheduler.Host.exe -Name ModuloSchedulerService -Description "Modulo Scheduler Background Service Host" -DisplayName "Modulo Scheduler Service" -Verbose
#>

<#===========================================================================================#
#    Verificando se a versão 3 do Microsoft Web Deploy está instalado
#===========================================================================================#>
if(Test-Path "C:\Program Files\IIS\Microsoft Web Deploy V3")
{
"Web Deploy V3 está instalado"
return $true;
}
else
{
"Web Deploy V3 não está instalado, vamos instalar"
.$Tools\WebDeploy\WebDeploy_amd64_en-US.msi
return $false;
}
#>

#===========================================================================================#
#    Realizando o Deploy das aplicações web
#===========================================================================================#

# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"

# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/RM"

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/$PORTAL"

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\Workflow.Services.Web.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/WF"

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\DataAnalytics\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsCacher"

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\DataAnalytics\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsService" 

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\DataAnalytics\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsUI"

# Deploy da aplicação Data MMI 
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\MMI\packages\Modulo.SICC.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/MMI" 

# Deploy da aplicação BCM
if(Test-Path IIS:\AppPools\$BCM)
{
"Realizando Deploy do BCM/GCN"
.\msdeploy.exe -verb=sync -source:package="$RaizInstall\RM_$VersionRM\Web.Applications\BCM.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/$BCM" 
return $true;
}
else
{
"BCM/GCN não existe"
return $false;
}
#>

#===========================================================================================#
#   Copiando a biblioteca DevExpress para Apps/bin
#===========================================================================================#
Copy-Item -Path "$RaizInstall\RM_$VersionRM\DevExpress\*.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose
Copy-Item -Path "$RaizInstall\RM_$VersionRM\DevExpress\*.dll" -Destination "$DIRsiteRM\WF\bin" -Force -Verbose
Copy-Item -Path "$RaizInstall\RM_$VersionRM\DevExpress\*.dll" -Destination "$DIRsiteRM\$PORTAL\bin" -Force -Verbose

#===========================================================================================#
#   Copiando o arquivo Modulo.RiskManager.DataAnalytics.Bootstrap
#===========================================================================================#
Copy-Item -Path "$RaizInstall\RM_$VersionRM\Web.Applications\DataAnalytics\Modulo.RiskManager.DataAnalytics.Bootstrap.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

#===========================================================================================#
#   Copiando o conteúdo da pasta do pacote Data Analytics\DashboardDesignerInstallers
#===========================================================================================#
Copy-Item -Path "$RaizInstall\RM_$VersionRM\Web.Applications\DataAnalytics\DashboardDesignerInstallers\*" -Destination "$DIRsiteRM\DataAnalyticsUI\Files" -Force -Verbose

#===========================================================================================#
#   Copiando os arquivos bin do MMI para o RM
#===========================================================================================#
Copy-Item -Path "$RaizInstall\RM_$VersionRM\Web.Applications\MMI\bin\rm\*" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

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
Start=WebAppPool "$PORTAL"
Start-WebAppPool "WF"
Start-WebAppPool "DataAnalyticsCacher"
Start-WebAppPool "DataAnalyticsService"
Start-WebAppPool "DataAnalyticsUI"
Start-WebAppPool "MMI"

# === Iniciando o BCM === #
if(Test-Path IIS:\AppPools\$BCM)
{
"Iniciando BCM/GCN"
Start-WebAppPool "$BCM"
return $true;
}
else
{
"BCM/GCN não existe"
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

<#===========================================================================================#
#   Verificando versão do ModSIC - A versão atual é a 3.0.12.0
#===========================================================================================#>
Get-WmiObject -Class Win32_Product -Filter "Name = 'modSIC 3.0'"
Get-WmiObject -Class Win32_Product -Filter "Name = 'modSIC 2.0'"
#>

<#===========================================================================================#
#   Desinstalando ModSIC
#===========================================================================================#>
$application = Get-WmiObject -Class Win32_Product -Filter "Name = 'modSIC 3.0'"
$application.Uninstall()
#>

<#===========================================================================================#
#   Limpando sobras do ModSIC 
#===========================================================================================#>
Remove-Item -Path "C:\Program Files (x86)\modSIC3" -Force -Recurse -Verbose
#>

<#===========================================================================================#
#   Instalando nova versão do ModSIC
#===========================================================================================#>
.$RaizInstall\RM_$VersionRM\Binaries\Modulo.Collect.Service*.msi
#>

Write-Output "Fim da execução do Script" 
$command.EndExecutionTime