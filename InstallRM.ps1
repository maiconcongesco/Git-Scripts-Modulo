##
<#===========================================================================================#
#===========================================================================================#
#
#   Instalação Risk Manager
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/InstallRM.ps1
#
#===========================================================================================#
#===========================================================================================#>

#===========================================================================================#
#   Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
#===========================================================================================#

# Geralmente essas váriaveis precisarão ser alteradas
$FileManual = "D:\Manual Versao 9.9 22.04.2020_v2.zip" # Caminho do Manual compactado.
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$RaizInstall = "D:\FilesRiskManager" # Diretório onde se encontrará a pasta do pacote de instalação depois de descompactado
$PackInstallRM = "D:\$RaizInstall\RM_9.9.2.7" # Diretório descompactado dos arquivos de instalação do Risk Manager
$PackRMZIP = "D:\RM_9.9.2.07.zip" # Caminho com o pacote de intalação compactado do Risk Manager
$NameSite="RiskManager" # Nome do Site do Risk Manager no IIS
$FileLicense = "D:\LicenseRM\modulelicenses.config" # Caminho do Arquivo de licença do RiskManager.
#$ConfigRM = "$RaizInstall/ConfigRM.zip" # Configs editados e disponibilizados na estrutura correta de pastas para o Risk Manager

# Ocasionalmente pode ser necessário alterar essa variáveis
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.

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

#===========================================================================================#
#   Instalando os Recursos Windows		         				
#===========================================================================================#
<#
Add-WindowsFeature web-server, web-webserver, web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45
# Verificando se os Recursos do Windows estão instalados
Get-WindowsFeature -Name web-server, web-webserver,  web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45 | Select-Object Name , InstallState
#>

#===========================================================================================#
#   Descompactando os arquivos das aplicações do Risk Manager
#===========================================================================================#
Expand-Archive -Path "$PackRMZIP" -DestinationPath "$RaizInstall" -Verbose
#>

<#===========================================================================================#
#   Criando um certificado auto assinado para o Risk Manager
#===========================================================================================#
### Resolver PS -- New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "RiskManager" -FriendlyName "RiskManager" -NotAfter (Get-Date).AddYears(10) 
#>

#===========================================================================================#
#   Criando o Site Risk Manager
#===========================================================================================#
New-Website -Name "$NameSite" -ApplicationPool "RiskManager" -PhysicalPath $DIRsiteRM -Port 443
#>

#===========================================================================================#
#   Criando os Applications Pool
#===========================================================================================#

# Navegue até o diretório do IIS
Set-Location "C:\Windows\system32\inetsrv\"

# Criar o Application Pool para o site RM:  
.\appcmd.exe add apppool /name:'RiskManager' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool RM:  
.\appcmd.exe add apppool /name:'RM' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool PORTAL:  
.\appcmd.exe add apppool /name:'PORTAL' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool Workflow:  
.\appcmd.exe add apppool /name:'WF' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar os Application Pools Data Analytics Cacher:  
.\appcmd.exe add apppool /name:'DataAnalyticsCacher' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  

# Criar os Application Pools Data Analytics Service:
.\appcmd.exe add apppool /name:'DataAnalyticsService' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  

# Criar os Application Pools Data Analytics UI:
.\appcmd.exe add apppool /name:'DataAnalyticsUI' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  

# Criar os Application MMI:
.\appcmd.exe add apppool /name:'MMI' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar os Application Pools BCM:
#.\appcmd.exe add apppool /name:'BCM' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  

<# Criar os Application Pools ETL:
.\appcmd.exe add apppool /name:'ETL' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  
#>

#===========================================================================================#
#   Alterando extensão dos arquivos dos serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
rename-item -path "$PackInstallRM\Binaries\Modulo Scheduler Service.zipx" -newname "Modulo Scheduler Service.zip" -Verbose # *> "$destinyPath\log-$date.txt"
rename-item -path "$PackInstallRM\Binaries\RiskManager.Service.zipx" -newname "RiskManager.Service.zip" -Verbose # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#   Descompactando os arquivos dos serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
Expand-Archive -Path "$PackInstallRM\Binaries\Modulo Scheduler Service.zip" -DestinationPath $DIRsvcScheduler -Verbose
Expand-Archive -Path "$PackInstallRM\Binaries\RiskManager.Service.zip" -DestinationPath $DIRsvcRM -Verbose
#>

<#===========================================================================================#
#    Criando os serviços Risk Manager e Modulo Scheduler
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

# Deploy da aplicação BCM 
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\BCM.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/BCM"

# Deploy da aplicação ETL 
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Modulo.Intelligence.EtlProcessor.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/ETL"
#>

#===========================================================================================#
#   Configurando o web application
#===========================================================================================#

# Nota: Manter o mesmo nome dos Applications Pools criados no passo “Criar o Application Pool”. 

# Configurando o web application Risk Manager:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/RM" /applicationPool:"RM"

# Configurando o web application PORTAL:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/PORTAL" /applicationPool:"PORTAL"

# Configurando o web application Workflow:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/WF" /applicationPool:"WF"

# Configurando o web application DataAnalyticsCacher:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/DataAnalyticsCacher" /applicationPool:"DataAnalyticsCacher"

# Configurando o web application DataAnalyticsService: 
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/DataAnalyticsService"  /applicationPool:"DataAnalyticsService"

# Configurando o web application DataAnalyticsUI:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/DataAnalyticsUI" /applicationPool:"DataAnalyticsUI"

# Configurando o web application MMI: 
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/MMI"  /applicationPool:"MMI"

# Configurando o web application BCM:  
#C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/BCM" /applicationPool:"BCM"

<# Configurando o web application ETL:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/ETL" /applicationPool:"ETL"
#>

#===========================================================================================#
#   Copiando a biblioteca DevExpress para Apps/bin
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\WF\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\PORTAL\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\BCM\bin" -Force -Verbose

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
#   Copiando o arquivo de licença
#===========================================================================================#

Copy-Item -Path "$FileLicense"  -Destination "$DIRsiteRM\RM" -Force -Verbose

#===========================================================================================#
#   Criando o diretório para o Manual
#===========================================================================================#

If(!(test-path $DIRsiteRM\RM\Manual\pt))
{
      New-Item -ItemType Directory -Force -Path $DIRsiteRM\RM\Manual\pt -Verbose
}
#>

#===========================================================================================#
#   Extraindo do Manual do Risk Manager para o App RM
#===========================================================================================#

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path "$FileManual" -DestinationPath "$DIRsiteRM\RM\Manual\pt" -Verbose
#>

#===========================================================================================#
#   Atualização dos arquivos de Config
#===========================================================================================#
Expand-Archive -Path "$ConfigRM" -DestinationPath "$DIRsiteRM" -Force -Verbose
Copy-Item -Path "$DIRsiteRM/RiskManager.Service/*.config" -Destination "$DIRsvcRM" -Force -Verbose
Remove-Item -Path "$DIRsiteRM/RiskManager.Service/" -Force -Recurse -Verbose
#>

#===========================================================================================#
#   Iniciando os WebAppPool
#===========================================================================================# 
#Get-WebAppPoolState DefaultAppPool # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "RiskManager" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "RM" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "PORTAL" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "WF" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "DataAnalyticsCacher" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "DataAnalyticsService" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "DataAnalyticsUI" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "MMI" # *> "$destinyPath\log-$date.txt"
#Start-WebAppPool "BCM" # *> "$destinyPath\log-$date.txt"
#Start-WebAppPool "ETLProcessor" # *> "$destinyPath\log-$date.txt"
#>

<#===========================================================================================#
#   Iniciando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "$RiskManagerService" | Start-Service
Get-Service -Name "$ModuloSchedulerService" | Start-Service
#>


# Versão do PowerShell
$PSVersionTable


Write-Output "Inicio da execução do Script" 

$command.StartExecutionTime



Write-Output "Fim da execução do Script" 

Get-Date