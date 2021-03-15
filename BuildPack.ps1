<##>
<#===========================================================================================#>
<#===========================================================================================#>
<#  Montagem de Pacote Risk Manager (Seguindo ritos e padrões do antigo Suporte)
<#  Autor: Maicon Santos        								            							                          
<#===========================================================================================#>
<#===========================================================================================#>
<##>
<#===========================================================================================#>
<#  Variáveis >>> ATENÇÃO: Um erro no preenchimento dessas variaveis e todo o script é comprometido
<#===========================================================================================#>
$DIRPack = "B:\Users\eusou\Desktop\9.10.2.16" # Diretório onde se encontra o pacote original baixado do repositório DEV
$Version = "9.10.2.16" # Versão do RiskManager contido no pacote
$FileModsic = "B:\OneDrive\- Modulo\- Risk Manager\ModSIC\PRD\Modulo.Collect.Service.v.3.0.12.msi" # ModSic em produção
$Knowledges = "B:\OneDrive\- Modulo\- Risk Manager\Knowledges"
$DevExpress = "B:\OneDrive\- Modulo\- Risk Manager\DevExpress"

<#===========================================================================================#>
<#  Testando se todos os arquivos necessários estão presentes no pacote Bruto baixado do repositório DEV 
<#===========================================================================================#>
test-path $DIRPack # Verifica a existencia do diretório onde se encontra o pacote original baixado do repositório DEV
test-path $DIRPack\BCMBuild*\packages # Verifica a existencia do diretório contendo o artefato BCM
test-path $DIRPack\CCM.Build*\packages # Verifica a existencia do diretório contendo os artefatos MMI
test-path $DIRPack\DataAnalytics* # Verifica a existencia do diretório contendo os artefatos DataAnalytics
test-path $DIRPack\Modulo.ReportDesigner*\packages # Verifica a existencia do diretório contendo o instalador do ReportDesigner
test-path $DIRPack\RiskMananger*\packages # Verifica a existencia do diretório contendo o artefatos para os serviços, RM, PORTAL e etc.
test-path $DIRPack\Workflow*\packages # Verifica a existencia do diretório contendo o artefato WF
test-path $DIRPack\Manual_RM* # Verifica a existencia do zip com o Manual

<#===========================================================================================#>
<#  Pasta Binaries 1-4
<#===========================================================================================#>
New-Item -ItemType Directory -Force -Path $DIRPack\PackRiskManager\Binaries
Move-Item "$DIRPack\RiskMananger*\packages\RiskManager.Service.zipx" $DIRPack\PackRiskManager\Binaries
Move-Item "$DIRPack\RiskMananger*\packages\Modulo Scheduler Service.zipx" $DIRPack\PackRiskManager\Binaries
Move-Item "$DIRPack\Modulo.ReportDesigner_10.0.0.3\packages\RM.ReportDesigner.Wix.msi" $DIRPack\PackRiskManager\Binaries
Copy-Item "$FileModsic" $DIRPack\PackRiskManager\Binaries

<#===========================================================================================#>
<#  Pasta DevExpress 2-4
<#===========================================================================================#>
New-Item -ItemType Directory -Force -Path $DIRPack\PackRiskManager\DevExpress
Copy-Item "$DevExpress\*" "$DIRPack\PackRiskManager\DevExpress" -Verbose -Force # Backup do Serviço do RiskManager

<#===========================================================================================#>
<#  Pasta Knowledges 3-4
<#===========================================================================================#>
New-Item -ItemType Directory -Force -Path $DIRPack\PackRiskManager\Knowledges 
Copy-Item -Path "$Knowledges\*" -Destination "$DIRPack\PackRiskManager\Knowledges" -Force -Verbose

<#===========================================================================================#>
<#  Pasta Web.Applications 4-4
<#===========================================================================================#>
New-Item -ItemType Directory -Force -Path $DIRPack\PackRiskManager\Web.Applications
Move-Item "$DIRPack\BCMBuild*\packages\BCM.zip" "$DIRPack\PackRiskManager\Web.Applications" -Force -Verbose
Move-Item "$DIRPack\RiskMananger*\packages\RM.Portal.zip" "$DIRPack\PackRiskManager\Web.Applications" -Force -Verbose
Move-Item "$DIRPack\RiskMananger*\packages\RM.WebApplication.zip" "$DIRPack\PackRiskManager\Web.Applications" -Force -Verbose
Move-Item "$DIRPack\Workflow*\packages\Workflow.Services.Web.zip" "$DIRPack\PackRiskManager\Web.Applications" -Force -Verbose
Move-Item "$DIRPack\DataAnalytics*" "$DIRPack\PackRiskManager\Web.Applications\DataAnalytics" -Force -Verbose
Move-Item "$DIRPack\CCM.Build*" "$DIRPack\PackRiskManager\Web.Applications\MMI" -Force -Verbose

<#===========================================================================================#>
<#  Remover arquivos não utilizado por padrão
<#===========================================================================================#>
Remove-Item "$DIRPack\PackRiskManager\Web.Applications\MMI\packages\Modulo.RiskManager.CICC.Integrator.Synchronizer.zip" -Force -Verbose
Remove-Item "$DIRPack\PackRiskManager\Web.Applications\DataAnalytics\DashboardDesignerInstallers\DashboardDesignerSetup_SQL32.exe" -Force -Verbose
Remove-Item "$DIRPack\PackRiskManager\Web.Applications\DataAnalytics\DashboardDesignerInstallers\SqlLocalDB_EN_32bits.MSI" -Force -Verbose
Remove-Item "$DIRPack\Modulo.ReportDesigner*" -Recurse -Force -Verbose
Remove-Item "$DIRPack\BCMBuild*" -Recurse -Force -Verbose
Remove-Item "$DIRPack\RiskMananger*" -Recurse -Force -Verbose
Remove-Item "$DIRPack\Workflow*" -Recurse -Force -Verbose

#===========================================================================================#
# Criando pacote zipado (Seguindo ritos e padrões do antigo Suporte)
#===========================================================================================#
Add-Type -Assembly "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory("$DIRPack\PackRiskManager", "$DIRPack\RM_$Version.zip")

# Abrindo pasta
Set-Location "$DIRPack"
Start-Process .