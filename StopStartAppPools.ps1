#===========================================================================================#
#						Script para parar e iniciar aplications Pools						#
#									Autor: Maicon Santos        							#            
#								 Data de criação: 01/04/2020    							#                          
#								Ultima modificação: 02/04/2020 								#
#===========================================================================================#

$LogFileLoc="D:\psscripts\RestartAppPoolLog.txt"
#$SepLine="==============================================="
$a = Get-Date | Out-File -append $LogFileLoc
#"Date: " + $a.ToShortDateString() | Out-File -append $LogFileLoc
#"Time: " + $a.ToShortTimeString() | Out-File -append $LogFileLoc

<#
Get-Content -Path '\\server\share\folder\apppoollist.txt' | ForEach-Object {
Restart-WebAppPool -Name $_
}
#>

{
Import-Module WebAdministration
cd IIS:\
cd .\AppPools
} 
# Get-WebAppPoolState DefaultAppPool | Out-File -append $

#===========================================================================================#
# 									Stop dos WebAppPool 									#
#===========================================================================================#
{
 Stop-WebAppPool "RiskManager" | Out-File -append $LogFileLoc
 Stop-WebAppPool "RM" | Out-File -append $LogFileLoc
 Stop-WebAppPool "Portal" | Out-File -append $LogFileLoc
 Stop-WebAppPool "WF" | Out-File -append $LogFileLoc
 Stop-WebAppPool "DataAnalyticsCacher" | Out-File -append $LogFileLoc
 Stop-WebAppPool "DataAnalyticsService" | Out-File -append $LogFileLoc
 Stop-WebAppPool "DataAnalyticsUI" | Out-File -append $LogFileLoc
} 
#===========================================================================================#
# 									Start dos WebAppPool 									#
#===========================================================================================#

<# 
# Get-WebAppPoolState DefaultAppPool | Out-File -append $
 Start-WebAppPool "RiskManager" | Out-File -append $LogFileLoc
 Start-WebAppPool "RM" | Out-File -append $LogFileLoc
 Start-WebAppPool "Portal" | Out-File -append $LogFileLoc
 Start-WebAppPool "WF" | Out-File -append $LogFileLoc
 Start-WebAppPool "DataAnalyticsCacher" | Out-File -append $LogFileLoc
 Start-WebAppPool "DataAnalyticsService" | Out-File -append $LogFileLoc
 Start-WebAppPool "DataAnalyticsUI" | Out-File -append $LogFileLoc
#>

#===========================================================================================#
#                       Start do DefaultAppPool com saída de Log                            #
#===========================================================================================#  
<#
 Start-Sleep -s 10
 Get-WebAppPoolState DefaultAppPool | Out-File -append $LogFileLoc
 Start-WebAppPool "DefaultAppPool"
 Get-WebAppPoolState DefaultAppPool | Out-File -append $LogFileLoc
 #>
 
