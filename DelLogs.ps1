#===========================================================================================#
#   Script para exclusão de logs e arquivos desnecessarios
#   <Filtros: Extensões e antiguidade dos arquivos>
#   Autor: Maicon Santos
#   Data de Criação: 01/04/2020
#   Ultima Modificação: 02/04/2020
#===========================================================================================#

$logPath = "D:\RiskManager\Logs, F:\RiskManager\Logs" # Separe por virgula as pastas onde estarão os logs
$XDays = 01  # Quantidade de dias que pretende reter o log.
$Extensions	= "*.log, *.xml" #  Separe por virgula as extensões dos arquivos

#===========================================================================================#
#===========================================================================================#
# 						ATENÇÃO! Essa remoção pode ser irreversível							#
#===========================================================================================#
#===========================================================================================#

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$Files = Get-Childitem $LogPath -Include $Extensions -Recurse | Where {$_.LastWriteTime -le `
(Get-Date).AddDays(-$XDays)}

foreach ($File in $Files) 
{
    if ($File -ne $NULL)
    {
        write-host "Deleting File $File" -ForegroundColor "DarkRed"
        Remove-Item $File.FullName | out-null
	}
}