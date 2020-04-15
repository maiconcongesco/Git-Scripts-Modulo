#===========================================================================================#
#       Script para criar, parar e iniciar Aplications Pools e para realização de Deploy    #
#								Autor: Maicon Santos        								#            
#							 Data de criação: 01/04/2020    								#                          
#							Ultima modificação: 13/04/2020 									#
#===========================================================================================#

$FileInstallWebApp = "E:\RM_9.8.9.01\Web_Applications"
$FileInstallWebAppDA = "E:\RM_9.8.9.01\Web_Applications\Web Applications\DataAnalytics"
#$DirInstallWebApp = E:\
$LogFileLoc="D:\psscripts\RestartAppPoolLog.txt"
#$SepLine="===========+===================================="
$a = Get-Date | Out-File -append $LogFileLoc
#"Date: " + $a.ToShortDateString() | Out-File -append $LogFileLoc
#"Time: " + $a.ToShortTimeString() | Out-File -append $LogFileLoc

#===========================================================================================#
#   >>>> OBS: Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools" <<<<    #
# ========================================================================================= #

#===========================================================================================#
#								           Stop IIS		         							#
#===========================================================================================#

<#
cmd /c 'iisrest /stop'
if(-not $?)
{
    'Falha ao parar o IIS.';
}`
#>

#===========================================================================================#
# 						        Restart em Lista de WebAppPool 								#
#===========================================================================================#
<#
Get-Content -Path '\\server\share\folder\apppoollist.txt' | ForEach-Object {
Restart-WebAppPool -Name $_
}
#>

#===========================================================================================#
# 									Stop dos WebAppPool 									#
#===========================================================================================#

{
Import-Module WebAdministration
cd IIS:\
cd .\AppPools
} 
# Get-WebAppPoolState DefaultAppPool | Out-File -append $

{
 Stop-WebAppPool "RiskManager" # | Out-File -append $LogFileLoc
 Stop-WebAppPool "RM" # | Out-File -append $LogFileLoc
 Stop-WebAppPool "Portal" # | Out-File -append $LogFileLoc
 Stop-WebAppPool "WF" # | Out-File -append $LogFileLoc
 Stop-WebAppPool "DataAnalyticsCacher" # | Out-File -append $LogFileLoc
 Stop-WebAppPool "DataAnalyticsService" # | Out-File -append $LogFileLoc
 Stop-WebAppPool "DataAnalyticsUI" # | Out-File -append $LogFileLoc
} 

#===========================================================================================#
#							    	Criar o Application Pool								#
#===========================================================================================#
{
# Navegue até interface do IIS com a conexão à Internet
cd "C:\Windows\system32\inetsrv\"

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
}


#===========================================================================================#
#									Deploy das aplicações web								#
#===========================================================================================#
{
# Navegue até interface do IIS com a conexão à Internet
cd "C:\Program Files\IIS\Microsoft Web Deploy V3"

# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebApp\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/RM98"
if(-not $?)
{
    'Falha no Deploy da aplicação Risk Manager.';
}`

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebApp\Workflow.Services.Web.zip" -dest:Auto setParam:"IIS Web Application Name""=RiskManager/WF98"
if(-not $?)
{
    'Falha no Deploy da aplicação Pool Data Analytics UI.';
}`

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebApp\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/PORTAL98"
if(-not $?)
{
    'Falha no Deploy da aplicação PORTAL.';
}`

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebAppDA\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsCacher98"
if(-not $?)
{
    'Falha no Deploy da aplicação Data Analytics Cacher.';
}`

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebAppDA\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsService98" 
if(-not $?)
{
    'Falha no Deploy da aplicação Data Analytics Service.';
}`

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebAppDA\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsUI98"
if(-not $?)
{
    'Falha no Deploy da aplicação Data Analytics UI.';
}`
}

#===========================================================================================#
#								Configurar a web application								#
#===========================================================================================#
{
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
} 

#===========================================================================================#
# 									Start dos WebAppPool 									#
#===========================================================================================#

<# 
# Get-WebAppPoolState DefaultAppPool | Out-File -append $
 Start-WebAppPool "RiskManager" | Out-File -append $LogFileLoc
 Start-WebAppPool "RM" | Out-File -append $LogFileLoc
 Start-WebAppPool "Portal" | Out-File -append $LogFileLoc
 Start-WebAppPool "WF" | Out-File -append $LogFileLoc
 Start-WebAppPool "DataAnalyticsCacher" | Out-File -append $LogFileLoc
 Start-WebAppPool "DataAnalyticsService" | Out-File -append $LogFileLoc
 Start-WebAppPool "DataAnalyticsUI" | Out-File -append $LogFileLoc
#>

#===========================================================================================#
#                       Start do DefaultAppPool com saída de Log                            #
#===========================================================================================#  
<#
 Start-Sleep -s 10
 Get-WebAppPoolState DefaultAppPool | Out-File -append $LogFileLoc
 Start-WebAppPool "DefaultAppPool"
 Get-WebAppPoolState DefaultAppPool | Out-File -append $LogFileLoc
 #>
 