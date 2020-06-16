# Geralmente essas váriaveis precisarão ser alteradas
$DIRsiteRM = "D:\RiskManager" # Diretório do Site do Risk Manager
$DIRbkp = "D:\BackupRM" # Diretório de backup do Risk Manager
$VersionRM = "9.9.2.07" # Versão do RM que será arquivado (Backup)

# Ocasionalmente pode ser necessário alterar essas variáveis
$DIRsvcRM = "C:\Program Files (x86)\RiskManager.Service" # Diretório do Serviço do Risk Manager.

# Raramente será necessário alterar essas variáveis
$DIRbkpfullRM = "$DIRbkp\$VersionRM" # Diretório onde faremos o Backup de todo o conteúdo dos serviços e sites do Risk Manager, se ela não existir o script a criará.

# Copia os arquivos e a estrutura de Diretórios.
Copy-Item "$DIRsiteRM" -Filter "Web.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "RM.Service.exe.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsvcRM" -Filter "tenants.config" -Destination "$DIRbkpfullRM\Configs" -Recurse -Force -Verbose
Copy-Item "$DIRsiteRM\RM" -Filter "modulelicenses*.config" -Destination "$DIRbkpfullRM\LicenseRM" -Recurse -Force -Verbose

# Apaga diretórios vazios - Removendo pastas vazias (à última sub-pasta), executado varias vezes pra ir removendo as novas sub-pastas vazias.
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
(Get-ChildItem “$DIRbkpfullRM” -r | Where-Object {$_.PSIsContainer -eq $True}) | Where-Object{$_.GetFileSystemInfos().Count -eq 0} | remove-item -Verbose
#>