<#
    .SYNOPSIS
        This script will update a defined list of BizTalk Application's tracking settings to be enabled or disabled for all Orchestrations, Send/ReceivePorts, Pipelines and Schemas.
    .DESCRIPTION
        This script is based on one originally created by Sandro Pereira which was obtained from here:
        http://sandroaspbiztalkblog.wordpress.com/2014/11/03/biztalk-devops-how-to-take-control-of-your-environment-disable-tracking-settings-in-biztalk-server-environment/
        I have extended it to update tracking settings to be enabled or disabled for a definable list of matching BizTalk applications. 
    .PARAMETER NameLike
        The optional Parameter that provides a LIKE clause for the BizTalk application Name. If ommitted, then all BizTalk applications will have their tracking updated.
    .PARAMETER SetTracking
        Can be either True or False. Determines if tracking is to be enabled or disabled
    .EXAMPLE
        C:\PS>.\UpdateTracking -NameLike Mexia -SetTracking True 
        This will update all BizTalk applications that have Mexia in their name and set their tracking to enabled.
    .NOTES
        Author: Matt Corr (Mexia) and Sandro Pereira (Devscope)
        Date:  18 November, 2014
    #>

    param( 
        [string]$NameLike = "", 
        [ValidateSet("True", "False")]
        [string] $SetTracking = "False")

    ######################################################################################################### 

    Function DetermineSendPortTracking($sp)
    {
        if ($SetTracking -eq "False")
        {
            return New-Object Microsoft.BizTalk.ExplorerOM.TrackingTypes
        }
        if ($sp.IsTwoWay)
        {
            return [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::BeforeSendPipeline -bor 
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::AfterSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesBeforeSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesAfterSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::BeforeReceivePipeline -bor 
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::AfterReceivePipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesBeforeReceivePipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesAfterReceivePipeline
        }
        else
        {
            return [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::BeforeSendPipeline -bor 
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::AfterSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesBeforeSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesAfterSendPipeline
        }
    }

    ######################################################################################################### 

    Function DetermineReceivePortTracking($rp)
    {
        if ($SetTracking -eq "False")
        {
            return New-Object Microsoft.BizTalk.ExplorerOM.TrackingTypes
        }
        if ($rp.IsTwoWay)
        {
            return [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::BeforeSendPipeline -bor 
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::AfterSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesBeforeSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesAfterSendPipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::BeforeReceivePipeline -bor 
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::AfterReceivePipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesBeforeReceivePipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesAfterReceivePipeline
        }
        else
        {
            return [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::BeforeReceivePipeline -bor 
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::AfterReceivePipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesBeforeReceivePipeline -bor
                   [Microsoft.BizTalk.ExplorerOM.TrackingTypes]::TrackPropertiesAfterReceivePipeline
        }
    }

    ######################################################################################################### 
    # SQL Settings
    ######################################################################################################### 
    $BTSSQLInstance = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
    $BizTalkManagementDb = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName

    ######################################################################################################### 
    # Connect the BizTalk Management database
    ###################################################################################################### 
    [void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")
    $BTSCatalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
    $BTSCatalog.ConnectionString = "SERVER=$BTSSQLInstance;DATABASE=$BizTalkManagementDb;Integrated Security=SSPI"

    ######################################################################################################### 
    # Get the BizTalk applications that match the nameLike param (or all if not specified)
    ######################################################################################################### 
    $BTSApplications = $BTSCatalog.Applications | Where-Object { $_.name -like "*$NameLike*"}

    if ($SetTracking -eq "False")
    {
        $OrchestrationTracking = [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::None
        $PipelineTracking = [Microsoft.BizTalk.ExplorerOM.PipelineTrackingTypes]::None
        $SchemaTracking = $false
        $mode = "Disabling"
    }
    else
    {
        $OrchestrationTracking = [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::OrchestrationEvents -bor
                                 [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::InboundMessageBody -bor
                                 [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::MessageSendReceive -bor
                                 [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::OutboundMessageBody -bor
                                 [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::ServiceStartEnd -bor
                                 [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::TrackPropertiesForIncomingMessages -bor
                                 [Microsoft.BizTalk.ExplorerOM.OrchestrationTrackingTypes]::TrackPropertiesForOutgoingMessages

        $PipelineTracking = [Microsoft.BizTalk.ExplorerOM.PipelineTrackingTypes]::InboundMessageBody -bor
                            [Microsoft.BizTalk.ExplorerOM.PipelineTrackingTypes]::OutboundMessageBody -bor
                            [Microsoft.BizTalk.ExplorerOM.PipelineTrackingTypes]::MessageSendReceive -bor
                            [Microsoft.BizTalk.ExplorerOM.PipelineTrackingTypes]::ServiceStartEnd
        $SchemaTracking = $true
        $mode = "Enabling"
    }

    ######################################################################################################### 
    # Set tracking setting for all artifacts inside selected BizTalk Applications
    ######################################################################################################### 
    foreach ($Application in $BTSApplications)
    {
        $appName = $Application.name

        Write-host "$mode tracking for application: $appName" -ForegroundColor Cyan
        # Disable tracking settings in orchestrations    
           $Application.orchestrations | %{ $_.Tracking = $OrchestrationTracking }

           # Set tracking settings in Send and Receive ports       
        $Application.SendPorts | %{ $_.Tracking    = DetermineSendPortTracking($_) } 
           $Application.ReceivePorts | %{ $_.Tracking = DetermineReceivePortTracking($_) }

        # Set tracking settings in pipelines        
           $Application.Pipelines | %{ $_.Tracking = $PipelineTracking }

           # Set tracking settings in Schemas
           $Application.schemas |     ?{ $_ -ne $null } |  ?{ $_.type -eq "document" } | %{ $_.AlwaysTrackAllProperties = $SchemaTracking }
    }
    # Save tracking settings changes
    $BTSCatalog.SaveChanges()
    Write-host "Finished $mode trackings settings for selected applications." -ForegroundColor Green
