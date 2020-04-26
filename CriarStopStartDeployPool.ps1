#===========================================================================================#
#								Autor: Maicon Santos        								            
#							 Data de criação: 01/04/2020    								                          
#							Ultima modificação: 24/04/2020
#
#       Criar, Restartar, Realizar Backup e Deploy dos Aplications Pools e Serviços								
#===========================================================================================#
{
#===========================================================================================#
#   >>> OBSERVAÇÕES IMPORTANTES <<<
#===========================================================================================#
#   Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools"
#===========================================================================================#
# Para o funcionamento de scripts PowerShell é necessário alterar a diretiva de execução de script do Windows 
# O cmdlet "Set-ExecutionPolicy" determina se os scripts PowerShell terão permissão de execução.
# Eu aconselho alterar para Irrestrito e após a execução do script voltar com política de execução corrente

# O cmdlet "Get-ExecutionPolicy" verifica a política de execução corrente
# O Windows PowerShell possui quatro políticas de execução diferentes:
# Para atribuir uma política específica, basta chamar Set-ExecutionPolicy seguido pelo nome da política apropriada.
# Set-ExecutionPolicy Restricted ### O PowerShell só pode ser usado no modo interativo. O script não poderá pode ser executado. 
# Set-ExecutionPolicy Unrestricted ###  Todos os scripts do Windows PowerShell podem ser executados.
# Set-ExecutionPolicy AllSigned ### Somente scripts assinados por um editor confiável podem ser executados.
# Set-ExecutionPolicy RemoteSigned ### Os scripts baixados devem ser assinados por um editor confiável antes que possam ser executados.
#===========================================================================================#
}
$FileWebApp = "E:\RM_9.8.9.01\Web_Applications"
$FileWebAppDA = "E:\RM_9.8.9.01\Web_Applications\Web Applications\DataAnalytics"
$DIRbkpfullRM = "C:\temp\NewFolder"
$DIRsvcRM = "C:\temp\NewFolder2"
$DIRsvcScheduler = "C:\temp\NewFolder3"
$DIRsiteRM = "C:\temp\NewFolder3"
# $PackInstallRM = "D:\Risk Manager Install"
# $LogFileLoc="D:\psscripts\RestartAppPoolLog.txt" # Local do Arquivos de Log
$Date = Get-Date -Format d-m-yyy # Indica data atual (dia-mês-ano) no arquivo de log
# $helper = New-Object -ComObject Shell.
#$Destination = "C:\pastadestino"
#$Source = "C:\arquivo.zip"
#$files = $helper.NameSpace($Source).Items()

#===========================================================================================#
#							    Instalação de Recursos Windows		         				
#===========================================================================================#
<#
add-windowsfeature web-server, web-webserver,  web-common-http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect,  Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering,  Web-App-Dev, Web-Net-Ext45, Web-AppInit, Web-ASP, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Scripting-Tools, MSMQ-Services, MSMQ-Server, MSMQ-Directory, MSMQ-HTTP-Support, MSMQ-Triggers,  NET-Framework-45-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, NET-WCF-TCP-PortSharing45

#===========================================================================================#
#   Stop IIS
#===========================================================================================#
{
<#
cmd /c 'iisrest /stop'
if(-not $?)
{
    'Falha ao parar o IIS.';
}`
#>
#===========================================================================================#
#   Restart em Lista de WebAppPool
#===========================================================================================#
{
<#
Get-Content -Path '\\server\share\folder\apppoollist.txt' | ForEach-Object {
Restart-WebAppPool -Name $_
}
#>
}
#===========================================================================================#
#   Stop dos WebAppPool
#===========================================================================================#
{
Import-Module WebAdministration
Set-Location IIS:\
Set-Location .\AppPools
# Get-WebAppPoolState DefaultAppPool *> "$destinyPath\log-$date.txt"

 Stop-WebAppPool "RiskManager" *> "$destinyPath\log-$date.txt"LogFileLoc
 Stop-WebAppPool "RM" *> "$destinyPath\log-$date.txt"LogFileLoc
 Stop-WebAppPool "Portal" *> "$destinyPath\log-$date.txt"LogFileLoc
 Stop-WebAppPool "WF" *> "$destinyPath\log-$date.txt"LogFileLoc
 Stop-WebAppPool "DataAnalyticsCacher" *> "$destinyPath\log-$date.txt"LogFileLoc
 Stop-WebAppPool "DataAnalyticsService" *> "$destinyPath\log-$date.txt"LogFileLoc
 Stop-WebAppPool "DataAnalyticsUI" *> "$destinyPath\log-$date.txt"LogFileLoc
}

#===========================================================================================#
#   Criação de diretório Backup
#===========================================================================================#
{
If(!(test-path $DIRbkpfullRM))
{
      New-Item -ItemType Directory -Force -Path $DIRbkpfullRM
}
}
#===========================================================================================#
#   Fazer Backup do RiskManager
#===========================================================================================#
{   
copy-item $DIRsvcRM $DIRbkpfullRM -Recurse -Verbose *> "$destinyPath\log-$date.txt"
copy-item $DIRsvcScheduler $DIRbkpfullRM -Recurse -Verbose *> "$destinyPath\log-$date.txt"
copy-item $DIRsiteRM $DIRbkpfullRM -Recurse -Verbose *> "$destinyPath\log-$date.txt"
}

#===========================================================================================#
#   Remover conteudo das pastas dos Serviços e APPs
#===========================================================================================#
{
Remove-Item -Path $DIRsvcRM\* -Recurse *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsvcScheduler\* -Recurse *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsiteRM\* -Recurse *> "$destinyPath\log-$date.txt"
}

#===========================================================================================#
#   Renomear e descompactar arquivos dos serviço RiskManager
#===========================================================================================#
<#
rename-item -path $PackInstallRM\Modulo Scheduler Service.zipx -newname "Modulo Scheduler Service.zip" *> "$destinyPath\log-$date.txt"
rename-item -path $PackInstallRM\RiskManager.Service.zipx -newname "RiskManager.Service.zipx" *> "$destinyPath\log-$date.txt"

# Descompactar arquivos compactados para a pasta dos serviços
# Na Powershell v3 extrai e copia os arquivos para pasta de destino 
# Unblock-File $Destination *> "$destinyPath\log-$date.txt" *> "$destinyPath\log-$date.txt"
# $helper.NameSpace($Destination).CopyHere($files) *> "$destinyPath\log-$date.txt"

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path $PackInstallRM\Modulo Scheduler Service.zip -DestinationPath $DIRsvcScheduler
Expand-Archive -Path $PackInstallRM\RiskManager.Service.zip -DestinationPath $DIRsvcRM
#>

#===========================================================================================#
#   Criar o Application Pool
#===========================================================================================#
{
<#
# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Windows\system32\inetsrv\"

# Criar o Application Pool RM:  
#.\appcmd.exe add apppool /name:'RiskManager' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool RM:  
.\appcmd.exe add apppool /name:'RM98' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"
if(-not $?)
{
    'Falha ao criar Application Pool RM.';
}`

# Criar o Application Pool PORTAL:  
.\appcmd.exe add apppool /name:'PORTAL98' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"
if(-not $?)
{
    'Falha ao criar Application Pool PORTAL.';
}`

# Criar o Application Pool Workflow:  
.\appcmd.exe add apppool /name:'WF98' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"
if(-not $?)
{
    'Falha ao criar Application Pool Workflow.';
}`

# Criar os Application Pools Data Analytics Cacher:  
.\appcmd.exe add apppool /name:'DataAnalyticsCacher98' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  
if(-not $?)
{
    'Falha ao criar Application Pool Data Analytics Cacher.';
}`

# Criar os Application Pools Data Analytics Service:
.\appcmd.exe add apppool /name:'DataAnalyticsService98' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  
if(-not $?)
{
    'Falha ao criar Application Pool Data Analytics Service.';
}`

# Criar os Application Pools Data Analytics UI:
.\appcmd.exe add apppool /name:'DataAnalyticsUI98' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  
if(-not $?)
{
    'Falha ao criar Application Pool Data Analytics UI.';
}`
#>
}

#===========================================================================================#
#    Deploy das aplicações web
#===========================================================================================#
{
# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"

# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/RM98"
if(-not $?)
{
    'Falha no Deploy da aplicação Risk Manager.';
}`

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Workflow.Services.Web.zip" -dest:Auto setParam:"IIS Web Application Name""=RiskManager/WF98"
if(-not $?)
{
    'Falha no Deploy da aplicação Pool Data Analytics UI.';
}`

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/PORTAL98"
if(-not $?)
{
    'Falha no Deploy da aplicação PORTAL.';
}`

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$FileWebAppDA\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsCacher98"
if(-not $?)
{
    'Falha no Deploy da aplicação Data Analytics Cacher.';
}`

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$FileWebAppDA\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsService98" 
if(-not $?)
{
    'Falha no Deploy da aplicação Data Analytics Service.';
}`

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$FileWebAppDA\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsUI98"
if(-not $?)
{
    'Falha no Deploy da aplicação Data Analytics UI.';
}`
}

#===========================================================================================#
#   Configurar a web application
#===========================================================================================#
{
<#
# Nota: Manter o mesmo nome dos Applications Pools criados no passo “Criar o Application Pool”. 

# Configurando o web application Risk Manager:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/RM98" /applicationPool:"RM98"  
if(-not $?)
{
    'Falha na configuração do web application Risk Manager.';
}`

# Configurando o web application PORTAL:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/PORTAL98" /applicationPool:"PORTAL98"  
if(-not $?)
{
    'Falha na configuração do web application Portal.';
}`

# Configurando o web application Workflow:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/WF98" /applicationPool:"WF98"  
if(-not $?)
{
    'Falha na configuração do web application Workflow.';
}`

# Configurando o web application DataAnalyticsCacher:  
C:\Windows\system32\inetsrv\appcmd set app /app.name:"RiskManager/DataAnalyticsCacher98" /applicationPool:"DataAnalyticsCacher98"  
if(-not $?)
{
    'Falha na configuração do web application Data Analytics Cacher.';
}`

# Configurando o web application DataAnalyticsService: 
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"RiskManager/DataAnalyticsService98"  /applicationPool:"DataAnalyticsService98"  
if(-not $?)
{
    'Falha na configuração do web application Data Analytics Service.';
}`

# Configurando o web application DataAnalyticsUI:  
C:\Windows\system32\inetsrv\appcmd set app  /app.name:"RiskManager/DataAnalyticsUI98" /applicationPool:"DataAnalyticsUI98"
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
#Get-WebAppPoolState DefaultAppPool *> "$destinyPath\log-$date.txt"
 Start-WebAppPool "RiskManager" *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "RM" *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "Portal" *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "WF" *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "DataAnalyticsCacher" *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "DataAnalyticsService" *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "DataAnalyticsUI" *> "$destinyPath\log-$date.txt"LogFileLoc
#>

#===========================================================================================#
#   Start do DefaultAppPool com saída de Log
#===========================================================================================#  
<#
 Start-Sleep -s 10
 Get-WebAppPoolState DefaultAppPool *> "$destinyPath\log-$date.txt"LogFileLoc
 Start-WebAppPool "DefaultAppPool"
 Get-WebAppPoolState DefaultAppPool *> "$destinyPath\log-$date.txt"LogFileLoc
#>