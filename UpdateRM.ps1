#===========================================================================================#
#===========================================================================================#
#
#   Atualização Risk Manager
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/UpdateRM.ps1
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

$FileLicense = "D:\BackupRM\RiskManager\RM\modulelicenses.config" # Caminho do Arquivo de licença do RiskManager.
$FileManual = "Manual Versao 9.9 22.04.2020_v2.zip" # Versão do arquivo de licença do Manual.
$LogPath = "D:\BackupRM\"   # Caminho da pasta principal onde iremos buscar e limpar os logs, Separe por virgula se for mais de uma pasta.
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos que serão deletados.
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
$DIRbkpfullRM = "D:\BackupRM" # Diretório onde faremos o Backup de todo o conteúdo dos serviços e sites do Risk Manager, se ela não existir o script a criará.
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$PackInstallRM = "D:\FilesRiskManager\RM_9.9.2.7\" # Diretório com os arquivos de atualização do Risk Manager
$ModuloSchedulerService = "ModuloSchedulerService" # Nome existente do Serviço do Modulo Scheduler >>> ATENÇÃO: Esse nome deve está correto, caso contrário o script não irá excluir o serviço antigo.
$RiskManagerService =  "RiskManagerService" # Nome existente do Serviço do Risk Manager >>> ATENÇÃO: Esse nome deve está correto, caso contrário o script não irá excluir o serviço antigo.
#$helper = New-Object -ComObject Shell.
#$Destination = "C:\pastadestino"
#$Source = "C:\arquivo.zip"
#$files = $helper.NameSpace($Source).Items()

#===========================================================================================#
#   Parando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -DisplayName "Modulo*", "Risk*" # Verificando nome do serviço

Get-Service -DisplayName "$ModuloSchedulerService", "$RiskManagerService" | Stop-Service

#===========================================================================================#
#   Parando os WebAppPools
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
#	Limpando os Logs		>>> ATENÇÃO! Essa remoção pode ser irreversível
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
#   Criando o diretório de Backup
#===========================================================================================#

If(!(test-path $DIRbkpfullRM))
{
      New-Item -ItemType Directory -Force -Path $DIRbkpfullRM
}
#>

#===========================================================================================#
#   Fazendo o Backup do RiskManager
#===========================================================================================#
copy-item $DIRsvcRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsvcScheduler $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsiteRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#   Remover conteudo das pastas dos Serviços e APPs
#===========================================================================================#
Remove-Item -Path $DIRsvcRM\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsvcScheduler\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsiteRM\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#    Removendo os serviços Risk Manager e Modulo Scheduler
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
#   Renomeando e descompactando os arquivos dos serviços Risk Manager e Modulo Scheduler
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
#    Realizando o Deploy das aplicações web
#===========================================================================================#

# Navegue até interface do IIS com a conexão à Internet
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3"

# Deploy da aplicação RM  
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\RM.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/RM"

# Deploy da aplicação Workflow
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Workflow.Services.Web.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/WF"

# Deploy da aplicação PORTAL  
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\RM.PORTAL.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/PORTAL"

# Deploy da aplicação Data Analytics Cacher 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsCacher.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsCacher"

# Deploy da aplicação Data Analytics Service 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsService.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsService" 

# Deploy da aplicação Data Analytics UI 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\DataAnalytics\DataAnalyticsUI.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/DataAnalyticsUI"

# Deploy da aplicação Data MMI 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\MMI\packages\Modulo.SICC.WebApplication.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/MMI" 

# Deploy da aplicação BCM 
.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\BCM.zip" -dest:Auto -setParam:"IIS Web Application Name""=RiskManager/BCM"
#>

#===========================================================================================#
#   Cópia da biblioteca DevExpress para Apps/bin
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\RM\bin" -Force
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\WF\bin" -Force
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\PORTAL\bin" -Force
Copy-Item -Path "$PackInstallRM\DevExpress\*.dll" -Destination "$DIRsiteRM\BCM\bin" -Force

#===========================================================================================#
#   Cópia do arquivo Modulo.RiskManager.DataAnalytics.Bootstrap
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\Modulo.RiskManager.DataAnalytics.Bootstrap.dll" -Destination "$DIRsiteRM\RM\bin" -Force

#===========================================================================================#
#   Cópia do conteúdo da pasta do pacote Data Analytics\DashboardDesignerInstallers
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\Web.Applications\DataAnalytics\DashboardDesignerInstallers\*" -Destination "$DIRsiteRM\DataAnalyticsUI\Files" -Force

#===========================================================================================#
#   Cópia do arquivo de licença
#===========================================================================================#

Copy-Item -Path "$FileLicense"  -Destination "$DIRsiteRM\RM" -Force

#===========================================================================================#
#   Criando o diretório para o Manual
#===========================================================================================#

If(!(test-path $DIRsiteRM\RM\Manual))
{
      New-Item -ItemType Directory -Force -Path $DIRsiteRM\RM\Manual
}
#>

#===========================================================================================#
#   Extração do Manual do Risk Manager para o App RM
#===========================================================================================#

# Descompactar arquivos compactados para a pasta dos serviços
# Na Powershell v3 extrai e copia os arquivos para pasta de destino 
# Unblock-File $Destination # *> "$destinyPath\log-$date.txt" # *> "$destinyPath\log-$date.txt"
# $helper.NameSpace($Destination).CopyHere($files) # *> "$destinyPath\log-$date.txt"

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path "$PackInstallRM\$FileManual" -DestinationPath "$DIRsiteRM\RM\Manual"
#>

#===========================================================================================#
#   Reiniciando os WebAppPool
#===========================================================================================#
<# 
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
#>