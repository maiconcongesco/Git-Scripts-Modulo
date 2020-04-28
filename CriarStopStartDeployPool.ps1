#===========================================================================================#
#								Autor: Maicon Santos        								            
#							 Data de criação: 01/04/2020    								                          
#							Ultima modificação: 24/04/2020
#
#       Criar, Restartar, Realizar Backup e Deploy dos Aplications Pools e Serviços								
#===========================================================================================#
{
<#==========================================================================================#
#   >>> OBSERVAÇÕES IMPORTANTES <<<
#===========================================================================================#
#   Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools"
#===========================================================================================#
# Para o funcionamento de scripts PowerShell é necessário alterar a diretiva de execução de script do Windows 
# O cmdlet "Set-ExecutionPolicy" determina se os scripts PowerShell terão permissão de execução.
# Eu aconselho alterar para Irrestrito e após a execução do script voltar com política de execução corrente
 
O cmdlet "Get-ExecutionPolicy" verifica a política de execução corrente
O Windows PowerShell possui quatro políticas de execução diferentes:
Para atribuir uma política específica, basta chamar Set-ExecutionPolicy seguido pelo nome da política apropriada.
Set-ExecutionPolicy Restricted ### O PowerShell só pode ser usado no modo interativo. O script não poderá pode ser executado. 
Set-ExecutionPolicy Unrestricted ###  Todos os scripts do Windows PowerShell podem ser executados.
Set-ExecutionPolicy AllSigned ### Somente scripts assinados por um editor confiável podem ser executados.
Set-ExecutionPolicy RemoteSigned ### Os scripts baixados devem ser assinados por um editor confiável antes que possam ser executados.
# ===========================================================================================#>
}
$FileWebApp = "E:\RM_9.8.9.01\Web_Applications"
$FileWebAppDA = "E:\RM_9.8.9.01\Web_Applications\Web Applications\DataAnalytics"
# $DIRbkpfullRM = "C:\temp\NewFolder"
# $DIRsvcRM = "C:\temp\NewFolder2"
# $DIRsvcScheduler = "C:\temp\NewFolder3"
$DIRsiteRM = "D:\RiskManager"
# $PackInstallRM = "D:\Risk Manager Install"
# $LogFileLoc="D:\psscripts\RestartAppPoolLog.txt" # Local do Arquivos de Log
# $Date = Get-Date -Format d-m-yyy # Indica data atual (dia-mês-ano) no arquivo de log
# $helper = New-Object -ComObject Shell.
#$Destination = "C:\pastadestino"
#$Source = "C:\arquivo.zip"
#$files = $helper.NameSpace($Source).Items()

#===========================================================================================#
#   Instalação de Recursos Windows		         				
#===========================================================================================#
<#
# Intalação
Add-WindowsFeature web-server, web-webserver, web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45
# Verificação se está instalado
Get-WindowsFeature -Name web-server, web-webserver,  web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45 | Select-Object Name , InstallState
#>
<#===========================================================================================#
#   Stop dos WebAppPool (Se for uma atualização)
#===========================================================================================#
{
Import-Module WebAdministration
Set-Location IIS:\
Set-Location .\AppPools
# Get-WebAppPoolState DefaultAppPool # *> "$destinyPath\log-$date.txt"

 Stop-WebAppPool "RiskManager" # # *> "$destinyPath\log-$date.txt"
 Stop-WebAppPool "RM" # # *> "$destinyPath\log-$date.txt"
 Stop-WebAppPool "Portal" # # *> "$destinyPath\log-$date.txt"
 Stop-WebAppPool "WF" # # *> "$destinyPath\log-$date.txt"
 Stop-WebAppPool "DataAnalyticsCacher" # # *> "$destinyPath\log-$date.txt"
 Stop-WebAppPool "DataAnalyticsService" # # *> "$destinyPath\log-$date.txt"
 Stop-WebAppPool "DataAnalyticsUI" # # *> "$destinyPath\log-$date.txt"
}
#>

<#===========================================================================================#
#   Criação de diretório Backup (Se for uma atualização)
#===========================================================================================#
{
If(!(test-path $DIRbkpfullRM))
{
      New-Item -ItemType Directory -Force -Path $DIRbkpfullRM
}
}
#===========================================================================================#
#   Fazer Backup do RiskManager (Se for uma atualização)
#===========================================================================================#
{   
copy-item $DIRsvcRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsvcScheduler $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsiteRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
}

#===========================================================================================#
#   Remover conteudo das pastas dos Serviços e APPs (Se for uma atualização)
#===========================================================================================#
{
Remove-Item -Path $DIRsvcRM\* -Recurse # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsvcScheduler\* -Recurse # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsiteRM\* -Recurse # *> "$destinyPath\log-$date.txt"
}

#===========================================================================================#
#   Renomear e descompactar arquivos dos serviço RiskManager
#===========================================================================================#
<#
rename-item -path $PackInstallRM\Modulo Scheduler Service.zipx -newname "Modulo Scheduler Service.zip" # *> "$destinyPath\log-$date.txt"
rename-item -path $PackInstallRM\RiskManager.Service.zipx -newname "RiskManager.Service.zipx" # *> "$destinyPath\log-$date.txt"

# Descompactar arquivos compactados para a pasta dos serviços
# Na Powershell v3 extrai e copia os arquivos para pasta de destino 
# Unblock-File $Destination # *> "$destinyPath\log-$date.txt" # *> "$destinyPath\log-$date.txt"
# $helper.NameSpace($Destination).CopyHere($files) # *> "$destinyPath\log-$date.txt"

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path $PackInstallRM\Modulo Scheduler Service.zip -DestinationPath $DIRsvcScheduler
Expand-Archive -Path $PackInstallRM\RiskManager.Service.zip -DestinationPath $DIRsvcRM
#>

#===========================================================================================#
#   Criar o Application Pool
#===========================================================================================#
{
# Navegue até o diretório do IIS
Set-Location "C:\Windows\system32\inetsrv\"

# Criar o Application Pool RM:  
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
#>
}

<#===========================================================================================#
#   Criar um certificado auto assinado para o Risk Manager
#===========================================================================================#
New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "localhost" -FriendlyName "RiskManager" -NotAfter (Get-Date).AddYears(10) 
#>

<#===========================================================================================#
#   Criar o Site Risk Manager
#===========================================================================================#
New-Website -Name "RiskManager" -ApplicationPool "RiskManager" -PhysicalPath $DIRsiteRM -Port 443
#>

#===========================================================================================#
#    Deploy das aplicações web
#===========================================================================================#
{
# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"
}
# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/RM"

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Workflow.Services.Web.zip" -dest:Auto setParam:"IIS Web Application Name""=RiskManager/WF"

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/PORTAL"

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$FileWebAppDA\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsCacher"

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$FileWebAppDA\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsService" 

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$FileWebAppDA\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsUI"

#===========================================================================================#
#   Configurar a web application
#===========================================================================================#
{
<#
# Nota: Manter o mesmo nome dos Applications Pools criados no passo “Criar o Application Pool”. 

# Configurando o web application Risk Manager:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/RM" /applicationPool:"RM"  
if(-not $?)
{
    'Falha na configuração do web application Risk Manager.';
}`

# Configurando o web application PORTAL:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/PORTAL" /applicationPool:"PORTAL"  
if(-not $?)
{
    'Falha na configuração do web application Portal.';
}`

# Configurando o web application Workflow:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/WF" /applicationPool:"WF"  
if(-not $?)
{
    'Falha na configuração do web application Workflow.';
}`

# Configurando o web application DataAnalyticsCacher:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/DataAnalyticsCacher" /applicationPool:"DataAnalyticsCacher"  
if(-not $?)
{
    'Falha na configuração do web application Data Analytics Cacher.';
}`

# Configurando o web application DataAnalyticsService: 
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"RiskManager/DataAnalyticsService"  /applicationPool:"DataAnalyticsService"  
if(-not $?)
{
    'Falha na configuração do web application Data Analytics Service.';
}`

# Configurando o web application DataAnalyticsUI:  
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"RiskManager/DataAnalyticsUI" /applicationPool:"DataAnalyticsUI"
if(-not $?)
{
    'Falha na configuração do web application Data Analytics UI.';
}`
#>
} 

#===========================================================================================#
#   Start dos WebAppPool
#===========================================================================================#
<# 
#Get-WebAppPoolState DefaultAppPool # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "RiskManager" # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "RM" # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "Portal" # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "WF" # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "DataAnalyticsCacher" # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "DataAnalyticsService" # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "DataAnalyticsUI" # # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#   Start do DefaultAppPool com saída de Log
#===========================================================================================#  
<#
 Start-Sleep -s 10
 Get-WebAppPoolState DefaultAppPool # # *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "DefaultAppPool"
 Get-WebAppPoolState DefaultAppPool # # *> "$destinyPath\log-$date.txt"
#>