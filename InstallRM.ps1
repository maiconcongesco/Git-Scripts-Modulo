<#
#===========================================================================================#
#===========================================================================================#
#
#   Instalação Risk Manager
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/InstallRM.ps1
#
#===========================================================================================#
#===========================================================================================#

#==========================================================================================#
#   >>> OBSERVAÇÕES IMPORTANTES <<<
#===========================================================================================#
#   Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools"
#===========================================================================================#
# Em algumas situações pode ser necessário alterar a diretiva de execução de script do Windows.
O cmdlet "Set-ExecutionPolicy" determina se os scripts PowerShell terão permissão de execução. O cmdlet "Get-ExecutionPolicy" verifica a política de execução corrente, o cmdlet aplica Set-ExecutionPolicy a política.
Set-ExecutionPolicy Restricted ### O PowerShell só pode ser usado no modo interativo. O script não poderá pode ser executado. 
Set-ExecutionPolicy Unrestricted ###  Todos os scripts do Windows PowerShell podem ser executados.
Set-ExecutionPolicy AllSigned ### Somente scripts assinados por um editor confiável podem ser executados.
Set-ExecutionPolicy RemoteSigned ### Os scripts baixados devem ser assinados por um editor confiável antes que possam ser executados.
#>

#===========================================================================================#
#   Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
#===========================================================================================#

# Geralmente essas váriaveis precisarão ser alteradas
$VersionBKPdoRM = "9.9.2.7" # Versão do RM que será arquivado (Backup)
$DIRbkp = "D:\BackupRM" # Diretório de backup do Risk Manager
$FileManual = "D:\Manual Versao 9.9 22.04.2020_v2.zip" # Versão do arquivo de licença do Manual.
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$PackInstallRM = "D:\FilesRiskManager\RM_9.9.2.7" # Diretório com os arquivos de atualização do Risk Manager
$RaizInstall = "D:\FilesRiskManager"
$PackRMZIP = "D:\RM_9.9.2.07.zip"

# Ocasionalmente pode ser necessário alterar essa variáveis
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
$NameSite="RiskManager"

# Raramente será necessário alterar essa variáveis
$DIRbkpfullRM = "$DIRbkp\$VersionBKPdoRM" # Diretório onde faremos o Backup de todo o conteúdo dos serviços e sites do Risk Manager, se ela não existir o script a criará.
$FileLicense = "$DIRbkpfullRM\LicenseRM\modulelicenses.config" # Caminho do Arquivo de licença do RiskManager.

#===========================================================================================#

# Inicio da execução do Script
$command = Get-History -Count 1 # Vai Cronometrar o tempo que o script levará em execução
$command.StartExecutionTime 

#===========================================================================================#
#   Instalação de Recursos Windows		         				
#===========================================================================================#
<#
# Intalação
Add-WindowsFeature web-server, web-webserver, web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45
# Verificação se está instalado
Get-WindowsFeature -Name web-server, web-webserver,  web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45 | Select-Object Name , InstallState
#>

#===========================================================================================#
#   Descompactando os arquivos das aplicações do Risk Manager
#===========================================================================================#
Expand-Archive -Path "$PackRMZIP" -DestinationPath "$RaizInstall" -Verbose
#>

<#===========================================================================================#
#   Criar um certificado auto assinado para o Risk Manager
#===========================================================================================#
### Resolver PS -- New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "RiskManager" -FriendlyName "RiskManager" -NotAfter (Get-Date).AddYears(10) 
#>

#===========================================================================================#
#   Criar o Site Risk Manager
#===========================================================================================#
New-Website -Name "RiskManager" -ApplicationPool "RiskManager" -PhysicalPath $DIRsiteRM -Port 443
#>

#===========================================================================================#
#   Criar o Application Pool
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
.\appcmd.exe add apppool /name:'BCM' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  

# Criar os Application Pools ETL:
.\appcmd.exe add apppool /name:'ETL' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  
#>

#===========================================================================================#
#   Renomeando os arquivos dos serviços Risk Manager e Modulo Scheduler
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

#===========================================================================================#
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

# Deploy da aplicação BCM 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\BCM.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/BCM"

# Deploy da aplicação ETL 
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Modulo.Intelligence.EtlProcessor.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/ETL"
#>

#===========================================================================================#
#   Configurar a web application
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
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"$NameSite/DataAnalyticsService"  /applicationPool:"DataAnalyticsService"

# Configurando o web application DataAnalyticsUI:  
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"$NameSite/DataAnalyticsUI" /applicationPool:"DataAnalyticsUI"

# Configurando o web application MMI: 
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"$NameSite/MMI"  /applicationPool:"MMI"

# Configurando o web application BCM:  
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"$NameSite/BCM" /applicationPool:"BCM"

# Configurando o web application ETL:  
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"$NameSite/ETL" /applicationPool:"ETL"
#>



#===========================================================================================#
#   Cópia da biblioteca DevExpress para Apps/bin
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\WF\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\PORTAL\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\BCM\bin" -Force -Verbose

#===========================================================================================#
#   Cópia do arquivo Modulo.RiskManager.DataAnalytics.Bootstrap
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\Modulo.RiskManager.DataAnalytics.Bootstrap.dll" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

#===========================================================================================#
#   Cópia do conteúdo da pasta do pacote Data Analytics\DashboardDesignerInstallers
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\DashboardDesignerInstallers\*" -Destination "$DIRsiteRM\DataAnalyticsUI\Files" -Force -Verbose

#===========================================================================================#
#   Cópia do arquivo de licença
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
#   Extração do Manual do Risk Manager para o App RM
#===========================================================================================#

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path "$FileManual" -DestinationPath "$DIRsiteRM\RM\Manual\pt" -Verbose
#>

<#===========================================================================================#
#   Reiniciando os WebAppPool
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
Start-WebAppPool "BCM" # *> "$destinyPath\log-$date.txt"
#Start-WebAppPool "ETLProcessor" # *> "$destinyPath\log-$date.txt"
#>

<#===========================================================================================#
#   Iniciado os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "$RiskManagerService" | Start-Service
Get-Service -Name "$ModuloSchedulerService" | Start-Service
#>


Write-Output "Inicio da execução do Script" 

$command.StartExecutionTime



Write-Output "Fim da execução do Script" 

Get-Date