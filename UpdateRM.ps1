<#
#===========================================================================================#
#===========================================================================================#
#
#   Atualização Risk Manager
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/UpdateRM.ps1
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
$FileManual = "Manual Versao 9.9 22.04.2020_v2.zip" # Versão do arquivo de licença do Manual.
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$PackInstallRM = "D:\FilesRiskManager\RM_9.9.2.7" # Diretório com os arquivos de atualização do Risk Manager

# Ocasionalmente pode ser necessário alterar essa variáveis
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
$ModuloSchedulerService = "ModuloSchedulerService" # Execute o comando [Get-Service -Name "Modulo*", "Risk*"] sem os "[]" para descobrir o Nome do Serviço do Modulo Scheduler >>> ATENÇÃO: Esse nome deve está correto, caso contrário o script não irá excluir o serviço antigo.
$RiskManagerService =  "RiskManagerService" # Execute o comando [Get-Service -Name "Modulo*", "Risk*"] sem os "[]" para descobrir o Nome do Serviço do Risk Manager >>> ATENÇÃO: Esse nome deve está correto, caso contrário o script não irá excluir o serviço antigo.

# Raramente será necessário alterar essa variáveis
$DIRbkpfullRM = "$DIRbkp\$VersionBKPdoRM" # Diretório onde faremos o Backup de todo o conteúdo dos serviços e sites do Risk Manager, se ela não existir o script a criará.
$FileLicense = "$DIRbkpfullRM\LicenseRM\modulelicenses.config" # Caminho do Arquivo de licença do RiskManager.
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos que serão deletados.
$LogPath = "$DIRsvcRM", "$DIRsvcScheduler", "$DIRsiteRM"   # Caminho da pasta principal onde iremos buscar e limpar os logs, Separe por virgula se for mais de uma pasta.

#===========================================================================================#

# Inicio da execução do Script
$command = Get-History -Count 1 # Vai Cronometrar o tempo que o script levará em execução
$command.StartExecutionTime 

#===========================================================================================#
#   Parando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#

Get-Service -Name "$ModuloSchedulerService", "$RiskManagerService" | Stop-Service

#===========================================================================================#
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
copy-item $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsvcScheduler -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
copy-item $DIRsiteRM $DIRbkpfullRM -Recurse -Verbose # *> "$destinyPath\log-$date.txt"
#>

#===========================================================================================#
#   Criando diretório para Backup de Configs
#===========================================================================================#

If(!(test-path $DIRbkpfullRM\Configs))
{
      New-Item -ItemType Directory -Force -Path $DIRbkpfullRM\Configs
}
#>

#===========================================================================================#
#   Backup de Configs do arquivo de lincença do Risk Manager
#===========================================================================================#

# Copia os arquivos e a estrutura de Diretórios.
Copy-Item "$DIRsiteRM" -Filter "Web.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "RM.Service.exe.config, tenants.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "tenants.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsiteRM\RM" -Filter "modulelicenses*.config" -Destination "$DIRbkpfullRM\LicenseRM" -Recurse -Force -Verbose

# Apaga diretórios vazios
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
#>

#===========================================================================================#
#   Remover conteudo das pastas dos Serviços e APPs
#===========================================================================================#
Remove-Item -Path $DIRsvcRM\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsvcScheduler\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
Remove-Item -Path $DIRsiteRM\* -Recurse -Verbose -Force # *> "$destinyPath\log-$date.txt"
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

If(!(test-path $DIRsiteRM\RM\Manual))
{
      New-Item -ItemType Directory -Force -Path $DIRsiteRM\RM\Manual -Verbose
}
#>

#===========================================================================================#
#   Extração do Manual do Risk Manager para o App RM
#===========================================================================================#

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
Expand-Archive -Path "$PackInstallRM\$FileManual" -DestinationPath "$DIRsiteRM\RM\Manual" -Verbose
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
#>

<#===========================================================================================#
#   Iniciado os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#
Get-Service -Name "$RiskManagerService" | Start-Service
Get-Service -Name "$ModuloSchedulerService" | Start-Service
#>


Write-Output "Inicio da execução do Script" $command.StartExecutionTime


Write-Output "Fim da execução do Script" date