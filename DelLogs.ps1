#===========================================================================================#
#   Script para exclusão de logs e arquivos desnecessarios
#   <Filtros: Extensão e antiguidade dos arquivos>
#   Autor: Maicon Santos
#   Data de Criação: 01/04/2020
#   Ultima Modificação: 02/04/2020
#===========================================================================================#
# A váriavel LogPath é o caminho onde estará os logs ou arquivos que devem ser deletados.
# Combine quantas pastas forem necessárias. 
# Ex: "D:\RiskManager\Logs" ou "D:\RiskManager\Logs, F:\RiskManager\Logs
$logPath = "D:\RiskManager\Logs, F:\RiskManager\Logs"
# Defina a váriavel $XDias com a quantidade de dias que pretende reter o log.
$XDias = 01
# Defina a(s) extensões do(s) arquivo(s) que deverão.
# Combine quantas extensões forem necessárias. Ex: "*.log" ou "*.log, *.xml"
$Extensions	= "*.log, *.xml"

#===========================================================================================#
#===========================================================================================#
# 						ATENÇÃO! Essa remoção pode ser irreversível							#
#===========================================================================================#
#===========================================================================================#

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$Files = Get-Childitem $LogPath -Include $Extensions -Recurse | Where {$_.LastWriteTime -le `
(Get-Date).AddDays(-$XDias)}

foreach ($File in $Files) 
{
    if ($File -ne $NULL)
    {
        write-host "Deleting File $File" -ForegroundColor "DarkRed"
        Remove-Item $File.FullName | out-null
	}
}