#===========================================================================================#
#   Script para exclusão de logs e arquivos desnecessarios
#   <Filtros: Extensões e antiguidade dos arquivos>
#   Autor: Maicon Santos
#   Data de Criação: 01/04/2020
#===========================================================================================#

$LogPath = "D:\BackupRM\Modulo Scheduler Service\logs", "D:\BackupRM\RiskManager.Service\logs" # Separe por virgula as pastas onde estarão os logs
$XDays = 00  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.slog" #  Separe por virgula as extensões dos arquivos

#===========================================================================================#
#===========================================================================================#
# 						ATENÇÃO! Essa remoção pode ser irreversível							#
#===========================================================================================#
#===========================================================================================#

# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

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