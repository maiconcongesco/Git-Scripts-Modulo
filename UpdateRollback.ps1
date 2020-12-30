##
<#===========================================================================================#
#===========================================================================================#
#
#   UpdateRollback
#   Autor: Maicon Santos        								            							                          
#
#===========================================================================================#
#===========================================================================================#>

<#==========================================================================================#>
<#===========================================================================================#
#   Executando Rollback # Apenas nos raros casos de falha na atualização
#===========================================================================================#>
<#==========================================================================================#>

# Removendo arquivos da nova versão do Risk Mananger
Remove-Item -Path "$DIRsvcRM\*" -Force -Recurse -Verbose # Serviço do RiskManager
Remove-Item -Path "$DIRsvcScheduler\*" -Force -Recurse -Verbose # Serviço do Modulo Scheduler
Remove-Item -Path "$DIRsiteRM\*" -Force -Recurse -Verbose # Aplicações do Risk Manager

# Restaurando do backup os arquivos da versão arquivada
copy-item  "$DIRbkp\$VersionBKPRM" $DIRsvcRM -Recurse -Verbose # Serviço do RiskManager
copy-item  "$DIRbkp\$VersionBKPRM" $DIRsvcScheduler -Recurse -Verbose # Serviço do Modulo Scheduler
copy-item  "$DIRbkp\$VersionBKPRM" $DIRsiteRM -Recurse -Verbose # Aplicações do Risk Manager
#>

# O backup da base dados realizado antes da atualização deverá ser restaurado.