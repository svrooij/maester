# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()


<#

234 Checks to determine ifMDOSafeDocs Allow people to click through Protected View even if Safe Documents identified the file as malicious is disabled.

#>



class ORCA234 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA234()
    {
        $this.Control=234
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Do not let users click through Safe Documents for Office clients"
        $this.PassText="Click through is disabled for Safe Documents"
        $this.FailRecommendation="Do not let usres click through Protected View if Safe Documents identified the file as malicious"
        $this.Importance="Safe Documents can assist protecting files opened in Office appplications. Before a user is allowed to trust a file opened in Office 365 ProPlus using Protected View, the file will be verified by Microsoft Defender for Office 365. It is possible to allow users click through Protected View even if Safe Documents identified the file as malicious. It is recommended to configure Safe Documents to not let users click through Pretected View."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Safe Attachments Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Microsoft 365 Defender Portal - Safe attachments"="https://security.microsoft.com/safeattachmentv2"
            "Safe Documents in Microsoft 365 E5"="https://aka.ms/orca-atpp-docs-1"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        $ConfigObject = [ORCACheckConfig]::new()
        $ConfigObject.Object=$Config["AtpPolicy"].Name
        $ConfigObject.ConfigItem="AllowSafeDocsOpen"
        $ConfigObject.ConfigData=$Config["AtpPolicy"].AllowSafeDocsOpen
        # Determine if click through for SafeDocs inMDOis enabled or not
        If($Config["AtpPolicy"].AllowSafeDocsOpen -eq $true) 
        {
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")   
        }
        Else
        {
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")     
        }
        
        $this.AddConfig($ConfigObject)

    }

}
