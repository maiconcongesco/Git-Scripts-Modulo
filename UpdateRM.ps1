#===========================================================================================#
#===========================================================================================#
#
#   Criar, Restartar, Realizar Backup e Deploy dos Aplications Pools e Serviços
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/CriarStopStartDeployPool.ps1
#
#===========================================================================================#
#===========================================================================================#

<#==========================================================================================#
#   >>> OBSERVAÇÕES IMPORTANTES <<<
#===========================================================================================#
#   Necessário instalar o Microsoft Web Deploy V3 contido no "Pack Tools"
#===========================================================================================#
# Para o funcionamento de scripts PowerShell pode ser necessário alterar a diretiva de execução de script do Windows 
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

$LogPath = "D:\BackupRM\"   # Separe por virgula as pastas onde estarão os logs
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service"
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service"
$DIRbkpfullRM = "D:\BackupRM"
$DIRsiteRM = "D:\RiskManager"
$FileWebApp = "E:\RM_9.8.9.01\Web_Applications"
$PackInstallRM = "D:\FilesRiskManager\RM_9.9.2.7\"
$helper = New-Object -ComObject Shell.
#$Destination = "C:\pastadestino"
#$Source = "C:\arquivo.zip"
#$files = $helper.NameSpace($Source).Items()

#===========================================================================================#
#   Stop os serviços Modulo Scheduler e Risk Manager (Se for uma atualização)
#===========================================================================================#

Get-Service -DisplayName "Modulo Scheduler Service", "Risk Manager Service" | Stop-Service

#===========================================================================================#
#   Stop Site e WebAppPools (Se for uma atualização)
#===========================================================================================#
Stop-WebAppPool "RiskManager" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "RM" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "PORTAL" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "WF" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "DataAnalyticsCacher" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "DataAnalyticsService" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "DataAnalyticsUI" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "MMI" # *> "$destinyPath\log-$date.txt"
Stop-WebAppPool "BCM" # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#	Remover Restrição de uso do script
#===========================================================================================#
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#===========================================================================================#
#	Limpeza de Logs		>>> ATENÇÃO! Essa remoção pode ser irreversível
#===========================================================================================#

$Files = Get-Childitem $LogPath -Include $Extensions -Recurse | Where-Object {$_.LastWriteTime -le `
(Get-Date).AddDays(-$XDays)}

foreach ($File in $Files) 
{
    if ($NULL -ne $File)
    {
        write-host "Deleting File $File" -ForegroundColor "DarkRed"
        Remove-Item $File.FullName | out-null
	}
}

#===========================================================================================#
#   Criação de diretório Backup (Se for uma atualização)
#===========================================================================================#

If(!(test-path $DIRbkpfullRM))
{
      New-Item -ItemType Directory -Force -Path $DIRbkpfullRM
}
#>

#===========================================================================================#
#   Fazer Backup do RiskManager (Se for uma atualização)
#===========================================================================================#
copy-item $DIRsvcRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsvcScheduler $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsiteRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#   Remover conteudo das pastas dos Serviços e APPs (Se for uma atualização)
#===========================================================================================#
Remove-Item -Path $DIRsvcRM\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsvcScheduler\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsiteRM\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#    Remover os serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
Get-Service -DisplayName "Modulo Scheduler Service", "Risk Manager Service" # Verificar status do serviço

#Remove-Service -DisplayName "Modulo Scheduler Service", "Risk Manager Service"

<# Esse cmdlet foi introduzido no PowerShell 6.0
Remove-Service -Name "ModuloSchedulerService"
Remove-Service -Name "RiskManagerService"
#>

# Esse é o cmdlet que funciona no PowerShell 5
(Get-WmiObject Win32_Service -filter "name='ModuloSchedulerService'").Delete()
(Get-WmiObject Win32_Service -filter "name='RiskManagerService'").Delete()

#===========================================================================================#
#   Renomear e descompactar arquivos dos serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
#
rename-item -path "$PackInstallRM\Binaries\Modulo Scheduler Service.zipx" -newname "Modulo Scheduler Service.zip" # *> "$destinyPath\log-$date.txt"
rename-item -path "$PackInstallRM\Binaries\RiskManager.Service.zipx" -newname "RiskManager.Service.zip" # *> "$destinyPath\log-$date.txt"
#>

# Descompactar arquivos compactados para a pasta dos serviços
# Na Powershell v3 extrai e copia os arquivos para pasta de destino 
# Unblock-File $Destination # *> "$destinyPath\log-$date.txt" # *> "$destinyPath\log-$date.txt"
# $helper.NameSpace($Destination).CopyHere($files) # *> "$destinyPath\log-$date.txt"

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path "$PackInstallRM\Binaries\Modulo Scheduler Service.zip" -DestinationPath $DIRsvcScheduler
Expand-Archive -Path "$PackInstallRM\Binaries\RiskManager.Service.zip" -DestinationPath $DIRsvcRM
#>

#===========================================================================================#
#    Recriando os serviços Risk Manager e Modulo Scheduler
#===========================================================================================#
Set-Location "$DIRsvcRM"
New-Service -Name "RiskManagerService" -BinaryPathName RM.Service.exe
Set-Location "$DIRsvcScheduler"
New-Service -Name "ModuloSchedulerService" -BinaryPathName Modulo.Scheduler.Host.exe

#===========================================================================================#
#    Deploy das aplicações web
#===========================================================================================#

# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"

# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/RM"

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\Workflow.Services.Web.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/WF"

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/PORTAL"

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\DataAnalytics\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsCacher"

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\DataAnalytics\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsService" 

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\DataAnalytics\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsUI"

# Deploy da aplicação Data MMI 
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\MMI\packages\Modulo.SICC.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/MMI" 

# Deploy da aplicação BCM 
.\msdeploy.exe -verb=sync -source:package="$FileWebApp\Web.Applications\BCM.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/BCM"
#>

#===========================================================================================#
#   Start dos WebAppPool
#===========================================================================================#
<# 
#Get-WebAppPoolState DefaultAppPool # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "RiskManager" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "RM" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "Portal" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "WF" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "DataAnalyticsCacher" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "DataAnalyticsService" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "DataAnalyticsUI" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "MMI" # *> "$destinyPath\log-$date.txt"
Start-WebAppPool "BCM" # *> "$destinyPath\log-$date.txt"
#>