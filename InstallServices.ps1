##
<#===========================================================================================#>
<#===========================================================================================#>
<#
<#  Criação de serviços
<#  Autor: Maicon Santos        								            							                          
<#  https://github.com/maiconcongesco/Git-Scripts-Modulo/blob/master/InstallRM.ps1
<#
<#===========================================================================================#>
<#===========================================================================================#>

<#===========================================================================================#>
<#  Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
<#===========================================================================================#>
<# >>> ATENÇÃO <<< 
<# Geralmente essas váriaveis precisarão ser alteradas #>
$RaizInstall = "[Diretório onde estão os pacotes de instalação]" # Diretório onde se encontrará a pasta do pacote de instalação depois de descompactado
$VersionInstall = "[Versão do instalação do Risk Manager]" # Versão do que será instalada do Risk Manager ou do LGPD Manager (RM_x.x.x.x ou LGPD_x.x.x.x)
$Instance = "" # Sigla do nome da instancia, caso essa instalação não seja intanciada deixe as aspas vazias ""
<#===========================================================================================#>
<# Ocasionalmente pode ser necessário alterar essa variáveis #>
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service$Instance" # Diretório do Serviço do Risk Manager.
$DIRsvcScheduler = "C:\Program Files (x86)\Modulo Scheduler Service$Instance" # Diretório do Serviço do Modulo Scheduler.
<#===========================================================================================#>

<#===========================================================================================#>
<#  Descompactando os arquivos dos serviços Risk Manager e Modulo Scheduler
<#===========================================================================================#>
Expand-Archive -Path "$RaizInstall\$VersionInstall\Binaries\Modulo Scheduler Service.zip" -DestinationPath $DIRsvcScheduler -Verbose
Expand-Archive -Path "$RaizInstall\$VersionInstall\Binaries\RiskManager.Service.zip" -DestinationPath $DIRsvcRM -Verbose
#>

<#===========================================================================================#>
<#   Criando os serviços Risk Manager e Modulo Scheduler
<#===========================================================================================#>
New-Service -BinaryPathName $DIRsvcRM/RM.Service.exe -Name RiskManagerService$Instance -Description " Risk Manager$Instance Background Service Host" -DisplayName "$Instance Risk Manager Service" -Verbose
New-Service -BinaryPathName $DIRsvcScheduler/Modulo.Scheduler.Host.exe -Name ModuloSchedulerService$Instance -Description "Modulo Scheduler$Instance Background Service Host" -DisplayName "$Instance Modulo Scheduler Service" -Verbose
#>

<#===========================================================================================#>
<#   Verificando se os serviços foram criados adequadamente
<#===========================================================================================#>
Get-Service -Name "ModuloSchedulerService", "RiskManagerService" | Format-Table -Property Status,Name,DisplayName -AutoSize -Wrap
#>