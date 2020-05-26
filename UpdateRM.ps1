##
<#===========================================================================================#
#===========================================================================================#
#
#   Atualização Risk Manager
#   Autor: Maicon Santos        								            							                          
#   https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/UpdateRM.ps1
#
#===========================================================================================#
#===========================================================================================#>

#===========================================================================================#
#   Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
#===========================================================================================#

# Geralmente essas váriaveis precisarão ser alteradas
$VersionRM = "9.9.2.07" # Versão do RM que será arquivado (Backup)
$RaizInstall = "D:\FilesRiskManager" # Diretório onde se encontrará a pasta do pacote de instalação depois de descompactado
$DIRbkp = "D:\BackupRM" # Diretório de backup do Risk Manager
$FileManual = "$RaizInstall\Manual_RM_9.9_pt_br.zip" # Caminho do Manual compactado.
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$PackInstallRM = "$RaizInstall\RM_9.9.2.07" # Diretório descompactado dos arquivos de instalação do Risk Manager
$PackRMZIP = "$RaizInstall\RM_9.9.2.07.zip" # Caminho com o pacote de intalação compactado do Risk Manager
$NameSite = "RiskManager" # Nome do Site do Risk Manager no IIS
$ConfigRM = "$RaizInstall/ConfigRM.zip" # Configs editados e disponibilizados na estrutura correta de pastas para o Risk Manager

# Ocasionalmente pode ser necessário alterar essas variáveis
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service" # Diretório do Serviço do Modulo Scheduler.
$ModuloSchedulerService = "ModuloSchedulerService" # Execute o comando [Get-Service -Name "Modulo*", "Risk*"] sem os "[]" para descobrir o Nome do Serviço do Modulo Scheduler
$RiskManagerService =  "RiskManagerService" # Execute o comando [Get-Service -Name "Modulo*", "Risk*"] sem os "[]" para descobrir o Nome do Serviço do Modulo Scheduler

# Raramente será necessário alterar essas variáveis
$DIRbkpfullRM = "$DIRbkp\$VersionRM" # Diretório onde faremos o Backup de todo o conteúdo dos serviços e sites do Risk Manager, se ela não existir o script a criará.
$FileLicense = "$DIRbkpfullRM\LicenseRM\modulelicenses.config" # Caminho do Arquivo de licença do RiskManager.
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos que serão deletados.
$LogPath = "$DIRsvcRM", "$DIRsvcScheduler", "$DIRsiteRM"   # Caminho da pasta principal onde iremos buscar e limpar os logs, Separe por virgula se for mais de uma pasta.

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
#   Descompactando os arquivos das aplicações do Risk Manager
#===========================================================================================#
Expand-Archive -Path "$PackRMZIP" -DestinationPath "$RaizInstall" -Verbose

#===========================================================================================#
#   Parando os serviços Modulo Scheduler e Risk Manager
#===========================================================================================#

Get-Service -Name "$ModuloSchedulerService", "$RiskManagerService" | Stop-Service

<#===========================================================================================#
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
#Stop-WebAppPool "ETLProcessor" # *> "$destinyPath\log-$date.txt"
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
copy-item $DIRsvcRM $DIRbkpfullRM -Recurse -Verbose # Backup do Serviço do RiskManager
copy-item $DIRsvcScheduler $DIRbkpfullRM -Recurse -Verbose # Backup do Serviço do Modulo Scheduler
copy-item $DIRsiteRM $DIRbkpfullRM -Recurse -Verbose # Backup das Aplicações do Risk Manager
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
Copy-Item "$DIRsvcRM" -Filter "RM.Service.exe.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
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

<#===========================================================================================#
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
#.\msdeploy.exe -verb=sync -source:package="$PackInstallRM\Web.Applications\Modulo.Intelligence.EtlProcessor.zip" -dest:Auto -setParam:"IIS Web Application Name""=$NameSite/ETLProcessor"
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
#   Cópia de arquivos bin do MMI para o RM
#===========================================================================================#

Copy-Item -Path "$PackInstallRM\Web.Applications\MMI\bin\rm\*" -Destination "$DIRsiteRM\RM\bin" -Force -Verbose

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

#===========================================================================================#
#   Atualização dos arquivos de Config
#===========================================================================================#

Expand-Archive -Path "$ConfigRM" -DestinationPath "$DIRsiteRM" -Force -Verbose
Copy-Item -Path "$DIRsiteRM/RiskManager.Service/*.config" -Destination "$DIRsvcRM" -Force -Verbose
Remove-Item -Path "$DIRsiteRM/RiskManager.Service/" -Force -Recurse -Verbose
#>

#===========================================================================================#
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


# Versão do PowerShell
$PSVersionTable


Write-Output "Inicio da execução do Script" 

$command.StartExecutionTime



Write-Output "Fim da execução do Script" 

Get-Date