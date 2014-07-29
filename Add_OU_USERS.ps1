#######################################################################################################################  
# AUTHOR  : Yoan DA COSTA  
# DATE    : 27/07/2014  
# EDIT    : 27/07/2014
# COMMENT : 
#           EN : This script creates new Organizational Unit, 
#				 new Active Directory users,      
#                including different kind of properties, based 
#                on several .csv files
#
#           FR : Ce script crée de nouvelle Unité Organisationnelle (UO),  
#                de nouveaux utilisateurs Active Directory, 
#                incluent différente propriétés basés sur plusieurs fichiers .csv 
# VERSION : 1.0
###################################################################################################################### 
# EN : Defenition of variable  
#
# $CsvOu : Path where your OU list is saved
# $CsvUsers : Path where your users list is saved
# $DataSource : Variable containing the list of your OU
# $ChekModule : Variable containing the list of installed modules
# $Domain :  Path of your domain ex: DC=myDomain,DC=com          
# $Path_Root_OU : Path of your root OU ex: ou=root,DC=myDomain,DC=com
# $Root_OU :  Named your root OU 
#---------------------------------------------------------------------------------------------------------------------       
# FR : Définition des variables
#
#
# $CsvOu : Chemin d'accès du fichier contenant la liste des UO est stocké
# $CsvUsers : Chemin d'accès du fichier contenant la liste des Utilisateurs est stocké 
# $DataSource : Variable contenant la liste de vos UO
# $ChekModule : Variable contenant la liste des modules installés
# $Domain : Chemin d'accès à votre domaine ex: DC=monDomaine,DC=fr            
# $Root_OU : chemin d'accès à votre UO racine ex: ou=racine,DC=monDomaine,DC=fr 
######################################################################################################################
#
# EN : To add users create, csv file with this columns :
#   	Username,GivenName,Surname,DisplayName,UserPrincipalName,Password,Path
#
# 
#					===> This is a correct csv file : <===
#
# Username,GivenName,Surname,DisplayName,UserPrincipalName,Password,Path
# nmandela,Nelson,MANDELA,Nelson MANDELA,nmandela@monDomaine.fr,Passw0rd8,"OU=myOU,ou=root,DC=myDomain,DC=com ",,
#
#---------------------------------------------------------------------------------------------------------------------     
#
# FR : Pour l'ajout de nouveaux utilisateurs créez un fichier csv avec les colonnes suivantes :
#		Username,GivenName,Surname,DisplayName,UserPrincipalName,Password,Path
#
#
# AVERTISSEMENT : La version française d'Excel utilise des points-virgules 
#				  pour séparer les colonnes, pensez à les remplacer par des virgules.
#				  Il est possible que des guillemets supplémentaires se place dans les données de la colonne Path supprimer ces guillemets supplémentaires.
#						
#					===> Voici un exemple de fichier csv correct : <===
#
#	Username,GivenName,Surname,DisplayName,UserPrincipalName,Password,Pathd
#   nadeau,Dario,NADEAU,Dario NADEAU,dnadeau@monDomaine.fr,Passw0rd8,"OU=monOU,ou=racine,DC=monDomaine,DC=fr ",,
#
###################################################################################################################### 

# EN : Cheking ActiveDirectory module 			FR : Vérification module ActiveDirectory

$ChekModule=Get-Module
IF ($ChekModule.Name -eq "ActiveDirectory")
    {Write-Host "ActiveDirectory Module is installed"}
ELSEIF ($ChekModule.Name -ne "ActiveDirectory")  
    { Import-Module ActiveDirectory
      Write-Host "ActiveDirectory Module is installed now"}

	  
###################################################################################################################### 

# EN : Path of .CSV files						FR : Chemin d'accès aux fichiers .CSV

$CsvOu=Read-Host "Path OU list ex: c:\ou.csv"
$CsvUsers=Read-Host "Path Users list ex: c:\users.csv "

###################################################################################################################### 

# EN : Creation OU root 						FR : Création UO racine

$Domain = Read-Host "Path of your domain ex: DC=myDomain,DC=com"
$Root_OU = Read-Host "Name your root OU" 

New-ADOrganizationalUnit -Name $Root_OU -Path $Domain -ProtectedFromAccidentalDeletion $false


###################################################################################################################### 

# EN : Creation of OU in OU's root 				FR : Création des UO dans l'UO racine

$Path_Root_OU = "OU" + "=" + $Root_OU + "," + $Domain

$DataSource=import-csv $CsvOu
foreach($DataSource in $DataSource)
{
$Ou=$DataSource.organizationalUnit
New-ADOrganizationalUnit -Name $Ou -Path $Path_Root_OU -ProtectedFromAccidentalDeletion $false
} 


###################################################################################################################### 

# EN : Creation of AD users						FR : Création des utilisateurs AD

Import-Csv $CsvUsers | foreach-object {
New-ADUser -Name $_.DisplayName -SamAccountName $_.Username -GivenName $_.GivenName -SurName $_.Surname -AccountPassword (ConvertTo-SecureString "PasSw0rd" -AsPlainText -force) -UserPrincipalName $_.UserPrincipalName -Enabled $True -PasswordNeverExpires $True -Path $_.Path
}