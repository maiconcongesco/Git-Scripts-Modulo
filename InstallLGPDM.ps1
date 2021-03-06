##
<#===========================================================================================#>
<#===========================================================================================#>
<#
<#  Instalação LGPD Manager
<#  Autor: Maicon Santos        								            							                          
<#  https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/InstallLGPDM.ps1
<#
<#===========================================================================================#>
<#===========================================================================================#>

<#===========================================================================================#
#  Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
#===========================================================================================#
# >>> ATENÇÃO <<< 
<# Geralmente essas váriaveis precisarão ser alteradas #>

$DIRsiteRM = "D:\LGPDManager" # Diretório do Site do Risk Manager
$RaizInstall = "D:\FilesLGPDManager" # Diretório onde se encontrará a pasta do pacote de instalação depois de descompactado
$VersionInstall = "9.11.1.04" # Versão do que será instalada do Risk Manager
$NameSite="LGPDManager" # Nome do Site do Risk Manager no IIS
<#===========================================================================================#>
<# Ocasionalmente pode ser necessário alterar essa variáveis #>
$DIRsvcRM = "C:\Program Files (x86)\LGPDManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\LGPDModulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
# $Tools = "$RaizInstall\Tools\Web Deploy\WebDeploy_amd64_en-US.msi"
$FileLicense = "$RaizInstall\modulelicenses.config" # Caminho do Arquivo de licença do RiskManager.
$ConfigRM = "$RaizInstall\ConfigLGPDM.zip" # Configs editados e disponibilizados na estrutura correta de pastas para o Risk Manager
$PackInstallRM = "$RaizInstall\LGPDM_$VersionInstall" # Diretório descompactado dos arquivos de instalação do Risk Manager
$PackRMZIP = "$RaizInstall\LGPDM_$VersionInstall.zip" # Caminho com o pacote de intalação compactado do Risk Manager
$FileManual = "$RaizInstall\Manual_RM_9.9_pt_br.zip" # Caminho do Manual compactado.
<#===========================================================================================#>

<#==========================================================================================#>
<#  >>> OBSERVAÇÕES IMPORTANTES <<<
<#===========================================================================================#>
<#  Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools"
<#===========================================================================================#>
<#===========================================================================================#>
<### Versões do Powershell e sua integração e compatibilidade com Windows e Windows Server ###
Powershell 1.0 — Foi feito para Windows XP SP2, Windows Server 2003 SP1 e Windows Vista. E é um componente opcional para Windows Server 2008.
Powershell 2.0 — Integrado com o Windows 7 e Windows Server 2008 R2. No Windows XP está disponível com o SP3, para o Windows Server 2003 com o SP2, e Windows Vista com o SP1.
Powershell 3.0 — Integrado com o Windows 8 e Windows Server 2012. No Windows 7, Windows Server 2008 e Windows Server 2008 R2 está disponível nos respectivos SP1.
Powershell 4.0 — Integrado com o Windows 8.1 e com o Windows Server 2012 R2. No Windows 7, Windows Server 2008 R2 e Windows Server 2012 está disponível nos respectivos SP1.
Powershell 5.0 — Integrado com o Windows Server 2016, 2019 e Windows 10 (no update de aniversário). A compatibilidade com o Windows Vista e Seven (7), Windows Server 2008, 2008 R2, 2012 e 2012 R2.
<#===========================================================================================#>
<#===========================================================================================#>
<# Em algumas situações pode ser necessário alterar a diretiva de execução de script do Windows.
O cmdlet "Set-ExecutionPolicy" determina se os scripts PowerShell terão permissão de execução. O cmdlet "Get-ExecutionPolicy" verifica a política de execução corrente, o cmdlet aplica Set-ExecutionPolicy a política.
Set-ExecutionPolicy Restricted ### O PowerShell só pode ser usado no modo interativo. O script não poderá pode ser executado. 
Set-ExecutionPolicy Unrestricted ##<# Todos os scripts do Windows PowerShell podem ser executados.
Set-ExecutionPolicy AllSigned ### Somente scripts assinados por um editor confiável podem ser executados.
Set-ExecutionPolicy RemoteSigned ### Os scripts baixados devem ser assinados por um editor confiável antes que possam ser executados.
<#===========================================================================================#>
<#===========================================================================================#>

<# Inicio da execução do Script #>
$command = Get-History -Count 1 # Vai Cronometrar o tempo que o script levará em execução
$command.StartExecutionTime

<# Versão do PowerShell #>
$PSVersionTable

<#===========================================================================================#
#  Instalando os Recursos Windows		         				
#===========================================================================================#
# Add-WindowsFeature web-server, web-webserver, web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45
# Verificando se os Recursos do Windows estão instalados #
# Get-WindowsFeature -Name web-server, web-webserver,  web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45 | Select-Object Name , InstallState
#>

<#===========================================================================================#>
<#  Instalando o WebDeploy		         				
<#===========================================================================================#>
# Set-Location "$Tools"
# MsiExec.exe /i WebDeploy_x86_en-US.msi ADDLOCAL=ALL /qn /norestart LicenseAccepted=”0″
#>

<#===========================================================================================#>
<#  Descompactando os arquivos das aplicações do Risk Manager
<#===========================================================================================#>
Expand-Archive -Path "$PackRMZIP" -DestinationPath "$RaizInstall" -Verbose
#>

<#===========================================================================================#>
<#  Criando um certificado auto assinado para o Risk Manager
<#===========================================================================================#>
<#
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=LGPDManager" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\LocalMachine\My" -KeyUsageProperty Sign -KeyUsage CertSign -NotAfter (Get-Date).AddYears(10) 
#>

<# Esse cmdlet retorna uma lista de certificados instalados para CurrentUser "Cert:\CurrentUser\My" ou LocalComputer "Cert:\LocalMachine\My" #>
# Get-ChildItem -Path "Cert:\LocalMachine\My" | findstr RiskManager

<#===========================================================================================#>
<#  Criando o diretório para o site
<#===========================================================================================#>
If(!(test-path $DIRsiteRM))
{
      New-Item -ItemType Directory -Force -Path $DIRsiteRM
}
#>

<#===========================================================================================#>
<#  Criando o Site Risk Manager
<#===========================================================================================#>
New-Website -Name "$NameSite" -ApplicationPool "LGPDManager" -PhysicalPath "$DIRsiteRM" -Port 4433
#>

<#===========================================================================================#>
<#  Adicionando a ligação SSL ao site
<#===========================================================================================#>
<#
New-WebBinding -Name "RiskManager" -IP "*" -Port 443 -Protocol https
<# Pode listar  listar a binding collection com o seguinte comando:
Get-WebBinding 'RiskManager'

$cert = Get-ChildItem -Path cert:\LocalMachine\My\EEDEF61D4FF6EDBAAD538BB08CCAADDC3EE28FF
$enrollResult = Get-Certificate -Template SslWebServer -DnsName www.contoso.com -Url https://www.contoso.com/policy/service.svc -Credential $cert -CertStoreLocation cert:\LocalMachine\My
#>

<#===========================================================================================#>
<#  Criando os Applications Pool
<#===========================================================================================#>
<# Navegue até o diretório do IIS #>
Set-Location "C:\Windows\system32\inetsrv\"

<# Criar o Application Pool para o site RM #>  
.\appcmd.exe add apppool /name:'LGPDManager' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

<# Criar o Application Pool para LGPDM #>  
.\appcmd.exe add apppool /name:'LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

<# Criar o Application Pool RM #>
.\appcmd.exe add apppool /name:'RM_LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

<# Criar o Application Pool PORTAL #>
.\appcmd.exe add apppool /name:'PORTAL_LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

<# Criar o Application Pool Workflow #>
.\appcmd.exe add apppool /name:'WF_LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

<# Criar os Application Pools Data Analytics Cacher #>
.\appcmd.exe add apppool /name:'DataAnalyticsCacher_LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  

<# Criar os Application Pools Data Analytics Service #>
.\appcmd.exe add apppool /name:'DataAnalyticsService_LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  

<# Criar os Application Pools Data Analytics UI #>
.\appcmd.exe add apppool /name:'DataAnalyticsUI_LGPD' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  

<# Criar os Application MMI #>
# .\appcmd.exe add apppool /name:'MMI' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

<# Criar os Application Pools BCM #>
# .\appcmd.exe add apppool /name:'BCM' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  

<# Criar os Application Pools ETL #>
# .\appcmd.exe add apppool /name:'ETL' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  
#>

<#===========================================================================================#>
<#  Alterando extensão dos arquivos dos serviços Risk Manager e Modulo Scheduler
<#===========================================================================================#>
rename-item -path "$PackInstallRM\Binaries\Modulo Scheduler Service.zipx" -newname "Modulo Scheduler Service.zip" -Verbose
rename-item -path "$PackInstallRM\Binaries\RiskManager.Service.zipx" -newname "RiskManager.Service.zip" -Verbose
#>

<#===========================================================================================#>
<#  Descompactando os arquivos dos serviços Risk Manager e Modulo Scheduler
<#===========================================================================================#>
Expand-Archive -Path "$PackInstallRM\Binaries\Modulo Scheduler Service.zip" -DestinationPath $DIRsvcScheduler -Verbose
Expand-Archive -Path "$PackInstallRM\Binaries\RiskManager.Service.zip" -DestinationPath $DIRsvcRM -Verbose
#>

<#===========================================================================================#>
<#   Criando os serviços Risk Manager e Modulo Scheduler
<#===========================================================================================#>
New-Service -BinaryPathName $DIRsvcRM/RM.Service.exe -Name LGPDRiskManagerService -Description "LGPD Risk Manager Background Service Host" -DisplayName "Risk Manager Service" -Verbose
New-Service -BinaryPathName $DIRsvcScheduler/Modulo.Scheduler.Host.exe -Name LGPDModuloSchedulerService -Description "LGPD Modulo Scheduler Background Service Host" -DisplayName "Modulo Scheduler Service" -Verbose
#>

<#===========================================================================================#>
<#   Realizando o Deploy das aplicações web
<#===========================================================================================#>
# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"

<# Deploy da aplicação RM #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/RM_LGPD"

<# Deploy da aplicação LGPD #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\LGPD.Web.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/LGPD"

<# Deploy da aplicação Workflow #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Workflow.Services.Web.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/WF_LGPD"

<# Deploy da aplicação PORTAL #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/PORTAL_LGPD"

<# Deploy da aplicação Data Analytics Cacher #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsCacher_LGPD"

<# Deploy da aplicação Data Analytics Service #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsService_LGPD" 

<# Deploy da aplicação Data Analytics UI #>
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/DataAnalyticsUI_LGPD"

<# Deploy da aplicação Data MMI #>
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\MMI\packages\Modulo.SICC.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/MMI" 

<# Deploy da aplicação BCM #>
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\BCM.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/BCM"

<# Deploy da aplicação ETL #>
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Modulo.Intelligence.EtlProcessor.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/ETL"
#>

<#===========================================================================================#>
<#  Configurando o web application
<#===========================================================================================#>
# Nota: Manter o mesmo nome dos Applications Pools criados anteriormente.

<# Configurando o web application Risk Manager: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/RM_LGPD" /applicationPool:"RM_LGPD"

<# Configurando o web application LGPD: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/LGPD" /applicationPool:"LGPD"

<# Configurando o web application PORTAL: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/PORTAL_LGPD" /applicationPool:"PORTAL_LGPD"

<# Configurando o web application Workflow: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/WF_LGPD" /applicationPool:"WF_LGPD"

<# Configurando o web application DataAnalyticsCacher: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/DataAnalyticsCacher_LGPD" /applicationPool:"DataAnalyticsCacher_LGPD"

<# Configurando o web application DataAnalyticsService: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/DataAnalyticsService_LGPD"  /applicationPool:"DataAnalyticsService_LGPD"

<# Configurando o web application DataAnalyticsUI: #>
C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/DataAnalyticsUI_LGPD" /applicationPool:"DataAnalyticsUI_LGPD"

<# Configurando o web application MMI: #>
#C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/MMI"  /applicationPool:"MMI"

<# Configurando o web application BCM: #>
#C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/BCM" /applicationPool:"BCM"

<# Configurando o web application ETL: #>
#C:\Windows\system32\inetsrv\appcmd set app /app.name:"$NameSite/ETL" /applicationPool:"ETL"
#>

<#===========================================================================================#>
<#  Copiando a biblioteca DevExpress para Apps/bin
<#===========================================================================================#>
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\RM_LGPD\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\WF_LGPD\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\PORTAL_LGPD\bin" -Force -Verbose
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\LGPD\bin" -Force -Verbose
# Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\BCM\bin" -Force -Verbose

<#===========================================================================================#>
<#  Copiando o arquivo Modulo.RiskManager.DataAnalytics.Bootstrap
<#===========================================================================================#>
Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\Modulo.RiskManager.DataAnalytics.Bootstrap.dll" -Destination "$DIRsiteRM\RM_LGPD\bin" -Force -Verbose

<#===========================================================================================#>
<#  Copiando o conteúdo da pasta do pacote Data Analytics\DashboardDesignerInstallers
<#===========================================================================================#>
Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\DashboardDesignerInstallers\*" -Destination "$DIRsiteRM\DataAnalyticsUI_LGPD\Files" -Force -Verbose

<#===========================================================================================#>
<#  Copiando os arquivos bin do MMI para o RM
<#===========================================================================================#>
# Copy-Item -Path "$PackInstallRM\Web.Applications\MMI\bin\rm\*" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

<#===========================================================================================#>
<#  Copiando o arquivo de licença
<#===========================================================================================#>
Copy-Item -Path "$FileLicense"  -Destination "$DIRsiteRM\RM_LGPD" -Force -Verbose

<#===========================================================================================#>
<#  Criando o diretório para o Manual
<#===========================================================================================#>
If(!(test-path $DIRsiteRM\RM\Manual\pt))
{
      New-Item -ItemType Directory -Force -Path $DIRsiteRM\RM\Manual\pt -Verbose
}
#>

<#===========================================================================================#>
<#  Extraindo do Manual do Risk Manager para o App RM
<#===========================================================================================#>
Expand-Archive -Path "$FileManual" -DestinationPath "$DIRsiteRM\RM\Manual\pt" -Force -Verbose
#>

<#===========================================================================================#>
<#  Atualização dos arquivos de Config
<#===========================================================================================#>
Expand-Archive -Path "$ConfigRM" -DestinationPath "$DIRsiteRM" -Force -Verbose
Copy-Item -Path "$DIRsiteRM/RiskManager.Service/*.config" -Destination "$DIRsvcRM" -Force -Verbose
Remove-Item -Path "$DIRsiteRM/RiskManager.Service/" -Force -Recurse -Verbose
#>

<#===========================================================================================#>
<#  Aplicando permissões para Network Service nos diretórios, subdiretórios e arquivos
<#===========================================================================================#>
icacls "$DIRsiteRM" /grant NetworkService:"(OI)(CI)F"
icacls "$DIRsvcRM" /grant NetworkService:"(OI)(CI)F"
icacls "$DIRsvcScheduler" /grant NetworkService:"(OI)(CI)F"
#>

<#===========================================================================================#>
<#  Iniciando os WebAppPool
<#===========================================================================================#> 
#Get-WebAppPoolState DefaultAppPool
Start-WebAppPool "RiskManager"
Start-WebAppPool "RM"
Start-WebAppPool "PORTAL"
Start-WebAppPool "WF"
Start-WebAppPool "DataAnalyticsCacher"
Start-WebAppPool "DataAnalyticsService"
Start-WebAppPool "DataAnalyticsUI"
Start-WebAppPool "MMI"
#Start-WebAppPool "BCM"
#Start-WebAppPool "ETLProcessor"
#>

<#===========================================================================================#>
<#  Iniciando os serviços Modulo Scheduler e Risk Manager
<#===========================================================================================#>
Get-Service -Name "RiskManagerService" | Start-Service
Get-Service -Name "ModuloSchedulerService" | Start-Service



<# Versão do PowerShell #>
$PSVersionTable


Write-Output "Inicio da execução do Script" 

$command.StartExecutionTime



Write-Output "Fim da execução do Script"

Get-Date