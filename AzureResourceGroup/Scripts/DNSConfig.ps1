Configuration DNSConfig
{ 
     param
    ( 
        [string]$NodeName ='localhost',  
        [Parameter(Mandatory=$true)][string]$DomainName,
        [Parameter(Mandatory=$true)][string]$DomainAdminUsername,
        [Parameter(Mandatory=$true)][System.Security.SecureString]$DomainAdminPassword
    ) 
        
    #Import the required DSC Resources  
    Import-DscResource -Module xComputerManagement 
    Import-DscResource -Module xActiveDirectory

    $securePassword = ConvertTo-SecureString -AsPlainText $DomainAdminPassword -Force;
    $DomainAdminCred = New-Object System.Management.Automation.PSCredential($DomainAdminUsername, $securePassword);
   
    Node $NodeName
    { #ConfigurationBlock
    
        WindowsFeature DSCService {
            Name = "DSC-Service"
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }
         
        WindowsFeature ADDSInstall 
        {   
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            IncludeAllSubFeature = $true
        }
         
        WindowsFeature RSATTools 
        { 
            DependsOn= '[WindowsFeature]ADDSInstall'
            Ensure = 'Present'
            Name = 'RSAT-AD-Tools'
            IncludeAllSubFeature = $true
        }  
 
        xADDomain SetupDomain {
            DomainName= $DomainName
            DomainAdministratorCredential= $DomainAdminCred
            SafemodeAdministratorPassword= $DomainAdminCred
            DependsOn='[WindowsFeature]RSATTools'
        }
    #End Configuration Block    
    } 
}

# Restart-Computer -ComputerName "localhost" -Force