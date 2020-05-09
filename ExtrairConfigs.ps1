# Copiaremos os arquivos deste disco
$Fonte  = "D:\RiskManager" 

# Colocamos a data e hora nesta variável 
$Agora   = (Get-Date).ToString('MM_dd_yy_HH_mm_ss') 

# Concatenamos o disco de destino com a variável acima para abaixo criarmos o diretório.
$Dest    = "$("D:\CONFIG_")$($Agora)" 

# Cria o diretorio de destino
New-Item -ItemType Directory $Dest -Force

# Atenção aqui.......CUIDADO: se existir arquivos com o mesmo nome; o anterior sera sobrescrito.
# Copiamos apenas os arquivos, (repetindo) porem se existir arquivos com o mesmo nome; o anterior sera sobrescrito.
#Get-ChildItem $Fonte -Filter "Web.config" -Recurse -file | Copy-Item -Destination $Dest -Force

#Copia os arquivos e a estrutura de Diretórios.
Copy-Item "$Fonte" -Filter "*.config" -Destination "$Dest" -Recurse -Force

#Get-ChildItem -Path  "$Dest" -Recurse -exclude "*.config" | Remove-Item -force -recurse #Matem o *config

# Removendo pastas vazias (à última sub-pasta), executado varias vezes pra ir removendo as novas sub-pastas vazias.
(Get-ChildItem “$Dest” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object {$_.GetFileSystemInfos().Count -eq 0} | remove-item
(Get-ChildItem “$Dest” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object {$_.GetFileSystemInfos().Count -eq 0} | remove-item
(Get-ChildItem “$Dest” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object {$_.GetFileSystemInfos().Count -eq 0} | remove-item
(Get-ChildItem “$Dest” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object {$_.GetFileSystemInfos().Count -eq 0} | remove-item
(Get-ChildItem “$Dest” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object {$_.GetFileSystemInfos().Count -eq 0} | remove-item
