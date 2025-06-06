# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA102 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA102()
    {
        $this.Control="ORCA-102"
        $this.Area="Anti-Spam Policies"
        $this.Name="Advanced Spam Filter (ASF)"
        $this.PassText="Advanced Spam filter options are turned off"
        $this.FailRecommendation="Turn off Advanced Spam filter (ASF) options in Anti-Spam filter policies"
        $this.Importance="Enabling one or more of the ASF settings is an aggressive approach to spam filtering that can often cause false positives. The effectiveness of these settings in reducing spam has severely declined over the years. Use them with caution."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Low
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-spam settings"="https://security.microsoft.com/antispam"
            "Recommended settings for EOP and Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-6"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"]).Count
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) {

            $IsPolicyDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            $IncreaseScoreWithImageLinks = $($Policy.IncreaseScoreWithImageLinks) 
            $IncreaseScoreWithNumericIps = $($Policy.IncreaseScoreWithNumericIps) 
            $IncreaseScoreWithRedirectToOtherPort = $($Policy.IncreaseScoreWithRedirectToOtherPort) 
            $IncreaseScoreWithBizOrInfoUrls = $($Policy.IncreaseScoreWithBizOrInfoUrls) 
            $MarkAsSpamEmptyMessages = $($Policy.MarkAsSpamEmptyMessages) 
            $MarkAsSpamJavaScriptInHtml = $($Policy.MarkAsSpamJavaScriptInHtml) 
            $MarkAsSpamFramesInHtml = $($Policy.MarkAsSpamFramesInHtml) 
            $MarkAsSpamObjectTagsInHtml = $($Policy.MarkAsSpamObjectTagsInHtml) 
            $MarkAsSpamEmbedTagsInHtml = $($Policy.MarkAsSpamEmbedTagsInHtml) 
            $MarkAsSpamFormTagsInHtml = $($Policy.MarkAsSpamFormTagsInHtml) 
            $MarkAsSpamWebBugsInHtml = $($Policy.MarkAsSpamWebBugsInHtml) 
            $MarkAsSpamSensitiveWordList = $($Policy.MarkAsSpamSensitiveWordList) 
            $MarkAsSpamFromAddressAuthFail = $($Policy.MarkAsSpamFromAddressAuthFail) 
            $MarkAsSpamNdrBackscatter = $($Policy.MarkAsSpamNdrBackscatter) 
            $MarkAsSpamSpfRecordHardFail = $($Policy.MarkAsSpamSpfRecordHardFail) 
           
            $IsBuiltIn = $false
            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Determine if ASF options are off or not
            If($IncreaseScoreWithImageLinks -eq "On" -or $IncreaseScoreWithNumericIps -eq "On" -or $IncreaseScoreWithRedirectToOtherPort -eq "On" -or $IncreaseScoreWithBizOrInfoUrls -eq "On" -or $MarkAsSpamEmptyMessages -eq "On" -or $MarkAsSpamJavaScriptInHtml -eq "On" -or $MarkAsSpamFramesInHtml -eq "On" -or $MarkAsSpamObjectTagsInHtml -eq "On" -or $MarkAsSpamEmbedTagsInHtml -eq "On" -or $MarkAsSpamFormTagsInHtml -eq "On" -or $MarkAsSpamWebBugsInHtml -eq "On" -or $MarkAsSpamSensitiveWordList -eq "On" -or $MarkAsSpamFromAddressAuthFail -eq "On" -or $MarkAsSpamNdrBackscatter -eq "On" -or $MarkAsSpamSpfRecordHardFail -eq "On") {
                If($IncreaseScoreWithImageLinks -eq "On") {

                    $ConfigObject = [ORCACheckConfig]::new()

                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="IncreaseScoreWithImageLinks"
                    $ConfigObject.ConfigData=$IncreaseScoreWithImageLinks
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($IncreaseScoreWithNumericIps -eq "On") 
                {

                    $ConfigObject = [ORCACheckConfig]::new()

                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="IncreaseScoreWithNumericIps"
                    $ConfigObject.ConfigData=$IncreaseScoreWithNumericIps
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($IncreaseScoreWithRedirectToOtherPort -eq "On") 
                {

                    $ConfigObject = [ORCACheckConfig]::new()

                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="IncreaseScoreWithRedirectToOtherPort"
                    $ConfigObject.ConfigData=$IncreaseScoreWithRedirectToOtherPort
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($IncreaseScoreWithBizOrInfoUrls -eq "On") 
                {

                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="IncreaseScoreWithBizOrInfoUrls"
                    $ConfigObject.ConfigData=$IncreaseScoreWithBizOrInfoUrls
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamEmptyMessages -eq "On") 
                {

                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamEmptyMessages"
                    $ConfigObject.ConfigData=$MarkAsSpamEmptyMessages
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamJavaScriptInHtml -eq "On") 
                {
                    
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamJavaScriptInHtml"
                    $ConfigObject.ConfigData=$MarkAsSpamJavaScriptInHtml
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamFramesInHtml -eq "On") {
                                        
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamFramesInHtml"
                    $ConfigObject.ConfigData=$MarkAsSpamFramesInHtml
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamObjectTagsInHtml -eq "On") 
                {
                                                            
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamObjectTagsInHtml"
                    $ConfigObject.ConfigData=$MarkAsSpamObjectTagsInHtml
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamEmbedTagsInHtml -eq "On") 
                {
                                                                                
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamEmbedTagsInHtml"
                    $ConfigObject.ConfigData=$MarkAsSpamEmbedTagsInHtml
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamFormTagsInHtml -eq "On") 
                {
                                                                                                    
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamFormTagsInHtml"
                    $ConfigObject.ConfigData=$MarkAsSpamFormTagsInHtml
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamWebBugsInHtml -eq "On") 
                {
                                                                                                                        
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamWebBugsInHtml"
                    $ConfigObject.ConfigData=$MarkAsSpamWebBugsInHtml
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamSensitiveWordList -eq "On") 
                {
                                                                                                                                      
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamSensitiveWordList"
                    $ConfigObject.ConfigData=$MarkAsSpamSensitiveWordList
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamFromAddressAuthFail -eq "On") 
                {
                                                                                                                                                          
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamFromAddressAuthFail"
                    $ConfigObject.ConfigData=$MarkAsSpamFromAddressAuthFail
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamNdrBackscatter -eq "On") 
                {
                                                                                                                                                                              
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamNdrBackscatter"
                    $ConfigObject.ConfigData=$MarkAsSpamNdrBackscatter
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
                If ($MarkAsSpamSpfRecordHardFail -eq "On") 
                {
                                                                                                                                                                             
                    $ConfigObject = [ORCACheckConfig]::new()
                    
                    $ConfigObject.Object=$policyname
                    $ConfigObject.ConfigItem="MarkAsSpamSpfRecordHardFail"
                    $ConfigObject.ConfigData=$MarkAsSpamSpfRecordHardFail
                    $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                    $ConfigObject.ConfigWontApply=$ConfigWontApply
                    $ConfigObject.ConfigReadonly=$Policy.IsPreset
                    $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

                    $this.AddConfig($ConfigObject)

                }
    
            }
            else 
            {
                                                                                                                                                                        
                $ConfigObject = [ORCACheckConfig]::new()
                    
                $ConfigObject.Object=$policyname
                $ConfigObject.ConfigItem="ASF Options"
                $ConfigObject.ConfigData="Disabled"
                $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                $ConfigObject.ConfigWontApply=$ConfigWontApply
                $ConfigObject.ConfigReadonly=$Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                $this.AddConfig($ConfigObject)

            }
        }        

    }

}

