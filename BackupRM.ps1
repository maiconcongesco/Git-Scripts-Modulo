#===========================================================================================#
#	Script para parar e iniciar aplications Pools
#	<Filtros: Extensão e antiguidade dos arquivos>
#	Autor: Maicon Santos
#	Data de criação: 01/04/2020
#	Ultima modificação: 03/04/2020
#===========================================================================================#

# Passos
# 1 - Criar Pasta Backup <Ex: "D:/RiskManager Backup">
# 2 - Copiar Pastas de RiskManager para a Pasta Backup
# 3 - Remover conteudo das pastas do Serviço e do Site
# 4 - Renomear arquivos compactados dos serviço RiskManager
# 5 - Descompactar arquivos compactados para a pasta dos serviços 

$DIRbackupfullRM = "C:\temp\NewFolder"
$DIRbackupserviceRM = "C:\temp\NewFolder2"
$DIRbackupserviceMS = "C:\temp\NewFolder3"
$DIRbackupAPPs = "C:\temp\NewFolder3"
$PackInstallRM = "D:\Risk Manager Install"
$Source = "c:\arquivo.zip"
$Destination = "c:\pastadestino"

#===========================================================================================#
# 			1 - Criação de diretório Backup
#===========================================================================================#

If(!(test-path $DIRbackupfullRM))
{
      New-Item -ItemType Directory -Force -Path $DIRbackupfullRM
}

#===========================================================================================#
# 			2 - Fazer Backup do RiskManager
#===========================================================================================#
{
copy-item $DIRbackupserviceRM -destination $DIRbackupfullRM  -recurse
copy-item $DIRbackupserviceMS -destination $DIRbackupfullRM  -recurse
copy-item $DIRbackupAPPs -destination $DIRbackupfullRM  -recurse
}
#===========================================================================================#
# 			3 - Remover conteudo das pastas dos Serviços e APPs
#===========================================================================================#
{
Remove-Item -Path $DIRbackupserviceRM -Recurse
Remove-Item -Path $DIRbackupserviceMS -Recurse
Remove-Item -Path $DIRbackupAPPs -Recurse
}
#===========================================================================================#
# 			4 - Renomear arquivos compactados dos serviço RiskManager
#===========================================================================================#
{
rename-item -path $PackInstallRM\Modulo Scheduler Service.zipx -newname "Modulo Scheduler Service.zip"
rename-item -path $PackInstallRM\RiskManager.Service.zipx -newname "RiskManager.Service.zipx"
}
#===========================================================================================#
# 			5 - Descompactar arquivos compactados para a pasta dos serviços
#===========================================================================================#
{
Unblock-File $Destination
#apenas no PowerShell v3            

#chama a aplicação do zip e abre o arquivo zip
$helper = New-Object -ComObject Shell.Application
$files = $helper.NameSpace($Source).Items()

#copia os arquivos para pasta de destino
$helper.NameSpace($Destination).CopyHere($files)
}

# No Powershell v5 você pode utilizar os seguintes cmdlets pra descompactar.
#Expand-Archive -Path $Source -DestinationPath $Destination