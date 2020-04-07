#===========================================================================================#
# 			 Script para criação dos Aplications Pools e realização de Deploy				#
#								Autor: Maicon Santos        								#            
#							 Data de criação: 01/04/2020    								#                          
#							Ultima modificação: 02/04/2020 									#
#===========================================================================================#

$FileInstallWebApp = F:\FilesRiskManager\Web Applications
$FileInstallWebAppDA = F:\FilesRiskManager\Web Applications\DataAnalytics
$DirInstallWebApp = F:\RiskManager


# >>>> OBS: Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools" <<<< #
# ==================================================================================== #


#===========================================================================================#
#								Criar o Application Pool									#
#===========================================================================================#
{
# Navegue até interface do IIS com a conexão à Internet
cd "%windir%\system32\inetsrv\" 

# Criar o Application Pool da aplicação RM:  
.\appcmd.exe add apppool /name:'RiskManager' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool da aplicação RM:  
.\appcmd.exe add apppool /name:'RM' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool da aplicação Portal:  
.\appcmd.exe add apppool /name:'Portal' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar o Application Pool da aplicação Workflow:  
.\appcmd.exe add apppool /name:'WF' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"

# Criar os Application Pools da aplicação Data Analytics Cacher:  
.\appcmd.exe add apppool /name:'DataAnalyticsCacher' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  

# Criar os Application Pools da aplicação Data Analytics Cacher:
.\appcmd.exe add apppool /name:'DataAnalyticsService' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  	  

# Criar os Application Pools da aplicação Data Analytics Cacher:
.\appcmd.exe add apppool /name:'DataAnalyticsUI' /managedRuntimeVersion:v4.0 /autoStart:true /startMode:OnDemand /processModel.identityType:NetworkService /processModel.idleTimeout:00:00:00 /recycling.periodicRestart.time:00:00:0 "/+recycling.periodicRestart.schedule.[value='03:00:00']"  
}


#===========================================================================================#
#									Deploy das aplicações web								#
#===========================================================================================#
{
# Navegue até interface do IIS com a conexão à Internet
cd ../..
cd “%ProgramFiles%\IIS\Microsoft Web Deploy V3\”

# Deploy da aplicação Risk Manager  
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebApp\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name"="RiskManager/RM"

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebApp\Workflow.Services.Web.zip" -dest:Auto setParam:"IIS Web Application Name"="RiskManager/WF"

# Deploy da aplicação Portal  
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebApp\RM.Portal.zip" -dest:Auto -setParam:"IIS Web Application Name"="RiskManager/Portal"

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebAppDA\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name"="RiskManager/DataAnalyticsCacher"

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebAppDA\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name"="RiskManager/DataAnalyticsService" 

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$FileInstallWebAppDA\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name"="RiskManager/DataAnalyticsUI"
}

#===========================================================================================#
#								Configurar a web application								#
#===========================================================================================#
{
# Nota: Manter o mesmo nome dos Applications Pools criados no passo “Criar o Application Pool”. 

# Configurando a web application da aplicação Risk Manager:  
%windir%\system32\inetsrv\appcmd set app /app.name:"RiskManager/RM" /applicationPool:"RM"  

# Configurando a web application da aplicação Portal:  
%windir%\system32\inetsrv\appcmd set app /app.name:"RiskManager/Portal" /applicationPool:"Portal"  

# Configurando a web application da aplicação Workflow:  
%windir%\system32\inetsrv\appcmd set app /app.name:"RiskManager/WF" /applicationPool:"WF"  

# Configurando a web application da aplicação DataAnalyticsCacher:  
%windir%\system32\inetsrv\appcmd set app /app.name:"RiskManager/DataAnalyticsCacher" /applicationPool:"DataAnalyticsCacher"  

# Configurando a web application da aplicação DataAnalyticsService: 
%windir%\system32\inetsrv\appcmd set app  /app.name:"RiskManager/DataAnalyticsService"  /applicationPool:"DataAnalyticsService"  

# Configurando a web application da aplicação DataAnalyticsUI:  
%windir%\system32\inetsrv\appcmd set app  /app.name:"RiskManager/DataAnalyticsUI" /applicationPool:"DataAnalyticsUI"  
} 
