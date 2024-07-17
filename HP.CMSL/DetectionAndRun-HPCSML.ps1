function Check-Compliance {
    # Check system for compliance and set necessary variables
          function ClientDetection {
          Param([string]$exception)
         	if($exception -ne "")
      	{
      		$ReturnCode = "1"
      		$ReturnCodeDescription= 'Not compliant due to: '+ $exception
      	} 
      	
      	$Bios_Authentication_Detection_Event ="BIOS_Authentication_Detection_Script"
      	$Bios_Update_Detection_Event="BIOS_Update_Detection_Script"
      	$Generic_Detection_Event_Name ="Generic_Detection_Script"
      	$Prerequisites_Detect_Event = "Prerequisites_Detection_Script"
      	$ActiveFreeze_Detection_Event_Name ="FreezeRules_Detection_Script"
      	$Bios_Setting_Detection_Event ="BIOS_Setting_Detection_Script"
      	switch($Discovery)
      	{
      	"BiosAuthenticationDiscovery"
      	{
      		#add BIOS Authentication event :
      		
      		$BiosAuth = $EventDetails.PsObject.Copy()
      		$BiosAuth."11" =$Bios_Authentication_Detection_Event
      		$BiosAuth."12" = $currentState
      		$BiosAuth."13" = $targetState
      		$BiosAuth."16" ="1"
      		$BiosAuth."17" =$ReturnCodeDescription
      		$Events = @(@{ "22.1" = $BiosAuth })
      		Out-File $logFile -Append -InputObject "Bios Authentication Non-Compliance Detection before posting analytics"
      		
      	}
      	"BiosSettingsDiscovery"
      	{
      		$BiosAuth = $EventDetails.PsObject.Copy()
      		$BiosSetting = $EventDetails.PsObject.Copy()
      
      		#add BIOS Authentication event 
      		$BiosAuth."11" = $Bios_Authentication_Detection_Event
      		$BiosAuth."12" = $currentState
      		$BiosAuth."13" = $targetState
      		$BiosAuth."16" = "0"
      		$BiosAuth."17" = "BIOS Authentication policy is compliant"
      		
      		#add BIOS Settings event :
      		$BiosSetting."11" = $Bios_Setting_Detection_Event
      		$BiosSetting."16" = "1"
      		$BiosSetting."17" = $ReturnCodeDescription
      		$Events = @{ "22.1" = $BiosAuth }	, @{ "22.1" = $BiosSetting}
      		Out-File $logFile -Append -InputObject "Bios Setting Non-Compliance Detection before posting analytics"
      	}
      	"BiosUpdatesDiscovery"
      	{
      		$BiosAuth = $EventDetails.PsObject.Copy()
      		$BiosSetting = $EventDetails.PsObject.Copy()
      		$BiosUpdate = $EventDetails.PsObject.Copy()
      
      		#add BIOS Authentication event 
      		$BiosAuth."11" = $Bios_Authentication_Detection_Event
      		$BiosAuth."12" = $currentState
      		$BiosAuth."13" = $targetState
      		$BiosAuth."16" = "0"
      		$BiosAuth."17" = "BIOS Authentication policy is compliant"	
      
      		#add BIOS Settings event :
      		$BiosSetting."11" = $Bios_Setting_Detection_Event
      		$BiosSetting."16" = "0"
      		$BiosSetting."17" = "BIOS Setting policy is compliant"	
      
      		#add BIOS Update event :
      		$BiosUpdate."11" = $Bios_Update_Detection_Event
      		$BiosUpdate."12" = $currentVersionInfo
      		$BiosUpdate."13" = $targetVersionInfo
      		$BiosUpdate."16" ="1"
      		$BiosUpdate."17" =$ReturnCodeDescription		
      		$Events = @{ "22.1" = $BiosAuth }	, @{ "22.1" = $BiosSetting}	, @{ "22.1" = $BiosUpdate}
      		Out-File $logFile -Append -InputObject "Bios Update Non-Compliance Detection before posting analytics"
      	}
      	"AllPoliciesCompliant"
      	{
      
      		#add BIOS Authentication event :
      		$BiosAuth = $EventDetails.PsObject.Copy()
      		$BiosSetting = $EventDetails.PsObject.Copy()
      		$BiosUpdate = $EventDetails.PsObject.Copy()
      
      		$BiosAuth."11" = $Bios_Authentication_Detection_Event
      		$BiosAuth."12" = $currentState
      		$BiosAuth."13" = $targetState
      		$BiosAuth."16" ="0"
      		$BiosAuth."17" ="BIOS Authentication policy is compliant"
      
      		#add BIOS Settings event :
      		$BiosSetting."11" = $Bios_Setting_Detection_Event
      		$BiosSetting."16" = "0"
      		$BiosSetting."17" = "BIOS Setting policy is compliant"	
      
      		#add BIOS Update event :
      		$BiosUpdate."11" = $Bios_Update_Detection_Event
      		$BiosUpdate."12" = $currentVersionInfo
      		$BiosUpdate."13" = $targetVersionInfo 
      		$BiosUpdate."16" ="0"
      		$BiosUpdate."17" ="BIOS Update policy is compliant"		
      		$Events = @{ "22.1" = $BiosAuth }, @{ "22.1" = $BiosSetting}	, @{ "22.1" = $BiosUpdate}
      		Out-File $logFile -Append -InputObject "All policies compliance Detection before posting analytics"
      	}
      	"PreRequisitesDiscovery"
      	{
      		Out-File $logFile -Append -InputObject "Failed at Pre Requisite detection: $($_.Exception.Message)"
      	}
      	"ClientDetailsDiscovery"
      	{
      		Out-File $logFile -Append -InputObject "Failed at Client details detection: $($_.Exception.Message)"
      	}
      	"FreezeRulesDiscovery"
      	{
      		$ReturnCodeDescription = "Active Freeze Rules in Detection"
      		$freezeStartDate = $freezeStartDate.ToUniversalTime().ToString('yyyy-MM-dd')
      		if($freezeEndDate)
      		{
      			$freezeEndDate = $freezeEndDate.ToUniversalTime().ToString('yyyy-MM-dd')
      		}
      		$EventDetails."11" = $ActiveFreeze_Detection_Event_Name
      		$EventDetails."16" = "0"
      		$EventDetails."17" =$ReturnCodeDescription	
      		$EventDetails."14" = $freezeStartDate
      		$EventDetails."15" = $freezeEndDate
      		$Events = @(@{ "22.1" = $EventDetails })
      		Out-File $logFile -Append -InputObject "FreezeRules Detection before posting analytics"
      	}
      	Default 
      	{
      		$EventDetails."11" = $Generic_Detection_Event_Name
      		$EventDetails."16" = "1"
      		$EventDetails."17" =$ReturnCodeDescription	
      		$Events = @(@{ "22.1" = $EventDetails })
      		Out-File $logFile -Append -InputObject "Generic Non-Compliance Detection before posting analytics"
      	}
      	}
      	
      }
      
      try
      {      
         $logFolder = "$($Env:LocalAppData)\HPConnect\Logs"  
         $logFile = "502dad2c-71af-4e9b-b9a2-3a2222f85a02"
         $logPathDir = [System.IO.Path]::GetDirectoryName($logFolder)
      
         if ((Test-Path -Path $logPathDir) -eq $false) {
            New-Item -ItemType Directory -Force -Path $logPathDir | Out-Null
         }
         if ((Test-Path -Path $logFolder) -eq $false) {
            New-Item -ItemType directory -Force -Path $logFolder | Out-Null
            $oldPathDir = "$($Env:ProgramData)\HP\Endpoint"
            if (Test-Path -Path $oldPathDir) {
                Out-File "$logFolder\$logFile" -Append -InputObject "Copying existing logs from ProgramData to AppData"
                Copy-Item -Path "$oldPathDir\Logs\*" -Destination $logFolder -Recurse -ErrorAction Ignore | Out-Null
                Remove-Item -Path $oldPathDir -Recurse -ErrorAction Ignore
            }
         } 
         $date = Get-Date
         $logFile = $logFolder + "\" +  $logFile
         Out-File $logFile -Append -InputObject "====================== Discovery Script ======================"
         Out-File $logFile -Append -InputObject $date
         
          enum PolicyDiscovery
          {
                  FreezeRulesDiscovery
                  PreRequisitesDiscovery
                  BiosAuthenticationDiscovery
                  BiosSettingsDiscovery
                  BiosUpdatesDiscovery
                  ClientDetailsDiscovery
                  AllPoliciesCompliant
          }
         $exception = ""
          
         # Pre-requisites, i.e: HP-CMSL instalation
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::PreRequisitesDiscovery
         Out-File $logFile -Append -InputObject $Discovery
         function Get-LastestCMSLFromCatalog {
          Param([string]$catalog)
      
          $json = $catalog | ConvertFrom-Json
          $filter = $json."hp-cmsl" | Where-Object { $_.isLatest -eq $true }
          $sort = @($filter | Sort-Object -Descending {$_.version -As [version]})
          $sort[0]
      }
      
      # URI to get last HP-CMSL version approved for HP Connect
      $preReqUri = 'https://hpia.hpcloud.hp.com/downloads/cmsl/wl/hp-mem-client-prereq.json'
      $localDir = "$($Env:LocalAppData)\HPConnect\Tools"
      $sharedTools = "$($Env:ProgramFiles)\HPConnect"
      $maxTries = 3
      $triesInterval = 10
      
      # Read local metadata
      $localCatalog = "$localDir\hp-mem-client-prereq.json"
      $isLocalLocked = $false
      if ([System.IO.File]::Exists($localCatalog) -and [System.IO.Directory]::Exists("$sharedTools\hp-cmsl-wl")) {
          $local = Get-LastestCMSLFromCatalog(Get-Content -Path $localCatalog)
          $isLocalLocked = $local.isLocalLocked -eq $true
          Out-File $logFile -Append -InputObject "Current version of HP-CMSL-WL is $($local.version)"
      }
      else {
          $new = $true
          New-Item -ItemType Directory -Force -Path $localDir | Out-Null
          New-Item -ItemType Directory -Force -Path $sharedTools | Out-Null
      }
      
      if (-not $isLocalLocked) {
          # Download remote metadata
          $userAgent = "hpconnect-script"
          # Removing obsolete protocols SSL 3.0, TLS 1.0 and TLS 1.1
          [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]([System.Net.SecurityProtocolType].GetEnumNames() | Where-Object { $_ -ne "Ssl3" -and $_ -ne "Tls" -and $_ -ne "Tls11" })
      
          $failedToDownloadCatalog = $false
          $tries = 0
          while ($tries -lt $maxTries) {
              try {
                  $data = Invoke-WebRequest -Uri $preReqUri -UserAgent $userAgent -UseBasicParsing -ErrorAction Stop -Verbose 4>> $logFile
                  break
              }
              catch {
                  Out-File $logFile -Append -InputObject "Failed to retrieve HP-CMSL-WL catalog ($($tries+1)/$maxTries) : $($_.Exception.Message)"
                  if ($tries -lt $maxTries-1) {
                      if ($tries -lt $maxTries-1) {
                          # Wait some interval between tries
                          Start-Sleep -Seconds $triesInterval
                      }
                  }
                  else {
                      if ($new) {
                          throw "Unable to retrieve HP-CMSL-WL catalog"
                      }
                      else {
                          Out-File $logFile -Append -InputObject "Unable to retrieve HP-CMSL-WL catalog. The script will continue with the local version"
                          $failedToDownloadCatalog = $true
                      }
                  }
              }
              $tries = $tries + 1
          }
      
          if (-not $failedToDownloadCatalog) {
              $catalog = [System.IO.StreamReader]::new($data.RawContentStream).ReadToEnd()
              $remote = Get-LastestCMSLFromCatalog($catalog)
      
              if ($new -or [Version] $remote.version -gt [Version] $local.version) {
                  throw "A new version of HP-CMSL-WL was found, update local version to $($remote.version)"
              }
          }
      }
      else {
          Out-File $logFile -Append -InputObject "Using a local locked version of HP-CMSL-WL"
      }
      
      # Import CMSL modules from local folder
      Out-File $logFile -Append -InputObject "Import CMSL from $sharedTools\hp-cmsl-wl"
      $modules = @(
          'HP.Private',
          'HP.Utility',
          'HP.ClientManagement',
          'HP.Firmware',
          'HP.Notifications',
          'HP.Retail',
          'HP.Softpaq',
          'HP.Sinks',
          'HP.Repo',
          'HP.Consent',
          'HP.SmartExperiences'
      )
      foreach ($m in $modules) {
          if (Get-Module -Name $m) { Remove-Module -Force $m }
      }
      foreach ($m in $modules) {
          try {
              Import-Module -Force "$sharedTools\hp-cmsl-wl\modules\$m\$m.psd1" -ErrorAction Stop
          }
          catch {
              $exception = $_.Exception
              Out-File $logFile -Append -InputObject "Failed to import module $m"
              throw $exception
          }
      }
      
         # Gather client device details for Posting Analytics
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::ClientDetailsDiscovery
          Out-File $logFile -Append -InputObject "Gather client device details"
         	# function for compression
      	function Compress-Data 
      	{
      		<#
      		.Synopsis
      			Compresses data
      		.Description
      			Compresses data into a GZipStream
      		.Link
      			Expand-Data
      		.Link
      			http://msdn.microsoft.com/en-us/library/system.io.compression.gzipstream.aspx
      		.Example
      			$rawData = (Get-Command | Select-Object -ExpandProperty Name | Out-String)
      			$originalSize = $rawData.Length
      			$compressed = Compress-Data $rawData -As Byte
      			"$($compressed.Length / $originalSize)% Smaller [ Compressed size $($compressed.Length / 1kb)kb : Original Size $($originalSize /1kb)kb] "
      			Expand-Data -BinaryData $compressed
      		#>
      		[OutputType([String],[byte])]
      		[CmdletBinding(DefaultParameterSetName='String')]
      		param(
      		# A string to compress
      		[Parameter(ParameterSetName='String',
      			Position=0,
      			Mandatory=$true,
      			ValueFromPipelineByPropertyName=$true)]
      		[string]$String,
          
      		# A byte array to compress.
      		[Parameter(ParameterSetName='Data',
      			Position=0,
      			Mandatory=$true,
      			ValueFromPipelineByPropertyName=$true)]
      		[Byte[]]$Data,
          
      		# Determine how the data is returned.
      		# If set to byte, the data will be returned as a byte array. If set to string, it will be returned as a string.
      		[ValidateSet('String','Byte')]
      		[String]$As = 'string'   
      		)
          
      		process {
                 
      			if ($psCmdlet.ParameterSetName -eq 'String') {
      				$Data= foreach ($c in $string.ToCharArray()) {
      					$c -as [Byte]
      				}            
      			}
              
      			#region Compress Data
      			$ms = New-Object IO.MemoryStream                
      			$cs = New-Object System.IO.Compression.GZipStream ($ms, [Io.Compression.CompressionMode]"Compress")
      			$cs.Write($Data, 0, $Data.Length)
      			$cs.Close()
      			#endregion Compress Data
              
      			#region Output CompressedData
      			if ($as -eq 'Byte') {
      				$ms.ToArray()
                  
      			} elseif ($as -eq 'string') {
      				[Convert]::ToBase64String($ms.ToArray())
      			}
      			$ms.Close()
      			#endregion Output CompressedData        
      		}
      	}
      
      
      	# Params
      	$UOID = 'Q0FHIEFtbmVk'	
      
         # Prepare OS and device details for posting Client analytics
      	$HPCmslInfo = (Get-HPCMSLEnvironment)
      	$OSName = $HPCmslInfo.OsName
      	$OSBuildNumber =$HPCmslInfo.OsBuildNumber
      	$OSVersion =$HPCmslInfo.OsVersion
      	$OSArchitecture = $HPCmslInfo.OSArchitecture	
      	$OSDisplayVersion =$HPCmslInfo.OsVer	
      	$PowerShellBitness = $HPCmslInfo.Bitness	
      	$ProductId = $HPCmslInfo.CsSystemSKUNumber
      	$SerialNumber = Get-HPDeviceSerialNumber
      	$DeviceUUID = Get-HPDeviceUUID
      	$CmslVersion =$local.version
      	$SMBIOSVersion = Get-HPBIOSSettingValue -Name "System BIOS Version"	
      	$PlatformName = Get-HPBIOSSettingValue -Name "Product Name"
      	
      	# get powershell version
      	$PSVersion = $HPCmslInfo.PSVersion
      	$Major = $PSVersion.Major
      	$Minor = $PSVersion.Minor
      	$Build = $PSVersion.Build
      	$Revision = $PSVersion.Revision
      	$PowershellVersion = ($Major,$Minor,$Build,$Revision) -Join "."
      	
      	# Get Unit details 
      	$OS = Get-CimInstance -ClassName Win32_OperatingSystem
      	$Culture = [System.Globalization.CultureInfo]::GetCultures("SpecificCultures") | Where {$_.LCID -eq $OS.OSLanguage}
      	$RegionInfo = New-Object System.Globalization.RegionInfo $Culture.Name
      	$CountryCode = $RegionInfo.TwoLetterISORegionName
      	$OSLanguage =$OS.OSLanguage
      	$OSDetail = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")
      	$OSReleaseId =$OSDetail.ReleaseId
      	$UnitModel =Get-HPDeviceModel
      	$HPProductID=Get-HPDeviceProductID
      	$UnitPlatformID = Get-HPDeviceProductID
      
      	#TODO Confirm below 2 param details :
      	$UnitCollectionID =  [guid]::NewGuid()
      	$SessionID = [guid]::NewGuid()
      
      	# 2022-04-10T14:59:30-05:00
      	$Date = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmss')
      	$Version = "1.0"
      	$Provider = "HP Connect"
      	$ProviderVersion = "v1.0"
      	$EventCategory = "Usage"
      	$EventType = "Status"	
      
      	$ReturnCodeDescription =""
      	$ReturnCode = 0
      
      	# initialize unit
      	$Unit =@{
              V =$Version
      	    DT= $Date
      	    "0" = $SerialNumber
      		"1" = $ProductId
      	    "2" = $DeviceUUID
      	    "3" = $CountryCode
      	    "4" = $Provider
      	    "5" = $ProviderVersion
      	    "6" = $UnitModel
      	    "7" = $UnitPlatformID
      	    "8" = $UnitCollectionID	
            }	
      	
      	$EventDetails = New-Object -TypeName PsObject -Property @{
      	     DT = $Date
      		"1" = $UOID
      		"2" = $OSVersion
      		"3" = $PowershellVersion
      		"4" = $CmslVersion
      		"5" = $PlatformName
      		"6" = $PowerShellBitness
      		"7" = $SMBIOSVersion
      		"8" = $EventCategory
      		"9" = $EventType
      		"10" = $Provider
      		"11" = ""
      		"12" = "N/A"
      		"13" = "N/A"
      		"14" = $freezeStartDate
      		"15" = $freezeEndDate
      		"16" = $ReturnCode
      		"17" = $ReturnCodeDescription
      		"18" = $OSName
      		"19" = $OSBuildNumber
      		"20" = $OSArchitecture		
      		"21" = $OSLanguage
      		"22" = $OSDisplayVersion
      		"23" = $OSReleaseId
      	}	
      
           # Process freeze rules (if any)
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::FreezeRulesDiscovery
         Out-File $logFile -Append -InputObject $Discovery
            
      
         # Replace this with combined & ordered discovery scripts from various policy types
         # Authentication policy script
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::BiosAuthenticationDiscovery
         Out-File $logFile -Append -InputObject $Discovery
         
      
         # BIOS setting policy scripts
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::BiosSettingsDiscovery
         Out-File $logFile -Append -InputObject $Discovery
         # Array of bios settings hash table
      $settingsTable = @{'generic'=@{'Configure Legacy Support and Secure Boot'='Legacy Support Disable and Secure Boot Enable';'Legacy Support'='Disable';'Secure Boot'='Enable';'TPM Device'='Available';'TPM State'='Enable';};}
      $settingsFallbackTable = @{'Configure Legacy Support and Secure Boot'='';'Legacy Support'='';'Secure Boot'='';'TPM Device'='';'TPM State'='';};
      $biosSettings = @{}
      
      # Get the generic BIOS settings
      $selectedGenericRecord = @($settingsTable.GetEnumerator() | Where-Object -Property Name -Match "generic")
      if ($selectedGenericRecord.Count -eq 0)
      {
          Out-File $logFile -Append -InputObject "No generic settings applicable"
      }
      if ($selectedGenericRecord.Count -gt 1) {
          Out-File $logFile -Append -InputObject "Multiple generic settings entries, using the first"
      }
      if ($selectedGenericRecord.Count -gt 0) {
          $biosSettings = $selectedGenericRecord[0].Value
          Out-File $logFile -Append -InputObject "Generic BIOS settings selected"
      }
      
      $productName = Get-HPBIOSSettingValue -Name "Product Name"
      $baseboardId = Get-HPBIOSSettingValue -Name "System Board ID"
      
      # Get the BIOS settings for this specific system ID
      $selectedSpecificRecord = @($settingsTable.GetEnumerator() | Where-Object -Property Name -Match "$($baseboardId)\|(.*)")
      if ($selectedSpecificRecord.Count -eq 0)
      {
          Out-File $logFile -Append -InputObject "No specific settings applicable for platform: $productName, $baseboardId"
      }
      
      if ($selectedSpecificRecord.Count -gt 1) {
          Out-File $logFile -Append -InputObject "Multiple entries for the same system id ($baseboardId), using the first"
      }
      
      if ($selectedSpecificRecord.Count -gt 0) {
          $selectedSpecificRecord[0].Value.keys | ForEach-Object {$biosSettings[$_] = $selectedSpecificRecord[0].Value[$_]}
          Out-File $logFile -Append -InputObject "Specific BIOS settings selected"
      }
      
      if ($biosSettings.Count -gt 0) {
          $forceRemediation = $false  
          foreach ($item in $biossettings.GetEnumerator()) {
              $valueVariationMatch = $false
              $fallbackVariationMatch =$false
              $checkFallbackValueCompliance = $true
              try {
                      $currentSettingValue = Get-HPBIOSSettingValue -Name $item.Key
                      $settingList = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSEnumeration
                      $possibleValues = ($SettingList | Where-Object Name -eq $item.Key).PossibleValues 
                      # test against all value variations
                      foreach ($v in $item.Value) {
                          if ($item.Key -eq 'UEFI Boot Order') {
                              # Policy contains the complete list of devices including network
                              # In local system we compare only the order of the intersection
                              $v = ((($v) -Split ',') | Where-Object { (($currentSettingValue) -Split ',') -Contains $_ }) -Join ','
                          }
      
                          if ($currentSettingValue -eq $v) {
                              $valueVariationMatch = $true
                              breaK
                          }
      
                          # check first if possible values contains desired value before checking compliance against fallbacks
                          if ($currentSettingValue -ne $v -and $possibleValues -contains $v) {
                               Out-File $logFile -Append -InputObject "Policy is not compliant ,the biossetting $($item.Key) is not set to possible desired value."
                              $checkFallbackValueCompliance = $false
      						break
      					}
                      }
      
                      # check if value matches fallback values if present
                      if (-not $valueVariationMatch -and $checkFallbackValueCompliance) {                   
                          if ($settingsFallbackTable.ContainsKey($item.Key)) { 
      				        foreach ($v in $settingsFallbackTable[$item.Key]){
      					        if ($v -ne "" -and $currentSettingValue -eq $v -and $possibleValues -contains ($v)) {
      						        $fallbackVariationMatch = $true
                                      Out-File $logFile -Append -InputObject "Policy is compliant ,the biossetting $($item.Key) is set to fallback value instead of desired value."					
                                      break
      					        }				
                              }           
                          }  
                      }
      
                      if(-not $valueVariationMatch -and -not $fallbackVariationMatch) {
      				        Out-File $logFile -Append -InputObject "Setting $($item.Key) doesnt match desired value and needs to be updated to $($item.Value)"
                              $forceRemediation = $true
                      }
              }        
              catch [System.Management.Automation.ItemNotFoundException] {
                  # Ignore setting doesn't exist case
                  Out-File $logFile -Append -InputObject "Skipping setting that does not exist: $($item.Key)"
              }
              catch {
                  Out-File $logFile -Append -InputObject "Failed to get BIOS setting: $($item.Key), $($_.Exception.Message)"
              }
          }    
          if ($forceRemediation) {
              throw "BIOS setting values are not matching, run remediation"
          }
      }
      
      # No remediation needed
      Out-File $logFile -Append -InputObject "BIOS setting policy is compliant"
      
         # BIOS update policy scripts
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::BiosUpdatesDiscovery
         Out-File $logFile -Append -InputObject $Discovery
         
      
         # Post Analytics with compliance detection details   
         [PolicyDiscovery]$Discovery =[PolicyDiscovery]::AllPoliciesCompliant  
         Out-File $logFile -Append -InputObject $Discovery
         ClientDetection($exception)
         Write-Output "BIOS settings are compliant"
         #$remediationNeeded = $false
      }
      catch{
      
         # Post Analytics with non-compliance detection details   
         Out-File $logFile -Append -InputObject $_.Exception.Message
         $exception = $_.Exception.Message
         $exception
         ClientDetection($exception)
         Write-Output throw
         #$remediationNeeded = $true
      }
      
      
}

function Remediate-NonCompliance {
    # Fix any issues found by Check-Compliance function
          function ClientRemediation {
          Param([string]$exception)
         	if($exception -ne "")
      	{
      		$ReturnCode = "1"
      		$ReturnCodeDescription = 'Failure due to: '+ $exception
      		Out-File $logFile -Append -InputObject $ReturnCodeDescription
      	}  
         
      	$Bios_Authentication_Remediation_Event ="BIOS_Authentication_Remediation_Script"
      	$Bios_Update_Remediation_Event="BIOS_Update_Remediation_Script"
      	$Generic_Remediation_Event_Name ="Generic_Remediation_Script"
      	$Prerequisites_Remediation_Event = "Prerequisites_Remediation_Script"
      	$ActiveFreeze_Remediation_Event = "FreezeRules_Remediation_Script"
      	$Bios_Setting_Remediation_Event ="BIOS_Setting_Remediation_Script"
      	switch($Remediation)
      	{
      	"BiosAuthenticationRemediation"
      	{
      		#add BIOS Authentication event :
      
      		$BiosAuth = $EventDetails.PsObject.Copy()
      		$BiosAuth."11" = $Bios_Authentication_Remediation_Event
      		$BiosAuth."12" = $currentState
      		$BiosAuth."13" = $targetState
      		$BiosAuth."16" = "1"
      		$BiosAuth."17" = $ReturnCodeDescription
      		$Events = @(@{ "22.1" = $BiosAuth })
      		Out-File $logFile -Append -InputObject "Bios Authentication Remediation Failure"
      	}
      	"BiosSettingsRemediation"
      	{		
      		$BiosSetting = $EventDetails.PsObject.Copy()
      		
      		#add BIOS Settings event :
      		$BiosSetting."11" = $Bios_Setting_Remediation_Event
      		$BiosSetting."16" = "1"
      		$BiosSetting."17" = $ReturnCodeDescription
      		$Events = @(@{ "22.1" = $BiosSetting})
      		Out-File $logFile -Append -InputObject "Bios Setting Remediation Failure"
      	}
      	"BiosUpdatesRemediation"
      	{
      		$BiosUpdate = $EventDetails.PsObject.Copy()
      
      		#add BIOS Update event :
      		$BiosUpdate."11" = $Bios_Update_Remediation_Event
      		$BiosUpdate."12" = $currentVersionInfo
      		$BiosUpdate."13" = $targetVersionInfo
      		$BiosUpdate."16" = "1"
      		$BiosUpdate."17" = $ReturnCodeDescription
      		$Events = @(@{ "22.1" = $BiosUpdate})
      		Out-File $logFile -Append -InputObject "Bios Update Remediation Failure"
      	}
      	"AllPoliciesCompleted"
      	{
      		
      		$BiosAuth = $EventDetails.PsObject.Copy()  
      		#add BIOS Authentication event :
      		$BiosAuth."11" = $Bios_Authentication_Remediation_Event
      		$BiosAuth."12" = $currentState
      		$BiosAuth."13" = $targetState
      		$BiosAuth."16" = "0"
      		$BiosAuth."17" = "BIOS Authentication policy remediation completed"
      	
      		$BiosSetting = $EventDetails.PsObject.Copy()		
      		#add BIOS Settings event :
      		$BiosSetting."11" = $Bios_Setting_Remediation_Event
      		$BiosSetting."16" ="0"
      		$BiosSetting."17" = "BIOS Setting policy remediation completed"
      				
      		$BiosUpdate = $EventDetails.PsObject.Copy()  
      		#add BIOS Update event :
      		$BiosUpdate."11" = $Bios_Update_Remediation_Event
      		$BiosUpdate."12" = $currentVersionInfo
      		$BiosUpdate."13" = $targetVersionInfo
      		$BiosUpdate."16" = "0"
      		$BiosUpdate."17" = "BIOS Update policy remediation completed"
      
      		$Events = @{ "22.1" = $BiosAuth }, @{ "22.1" = $BiosSetting } 	, @{ "22.1" = $BiosUpdate}
      	}
      	"PreRequisitesRemediation"
      	{
      		$EventDetails.EventName = $Prerequisites_Remediation_Event	
      		Out-File $logFile -Append -InputObject "Failed at Pre Requisite Remediation: $($_.Exception.Message)" 
      	}
      	"ClientDetailsRemediation"
      	{
      		Out-File $logFile -Append -InputObject "Failed at Client details remediation: $($_.Exception.Message)"
      	}
      	"FreezeRulesRemediation"
      	{
      		$ReturnCodeDescription = "Active Freeze Rules in Remediation"
      		 $freezeStartDate = $freezeStartDate.ToUniversalTime().ToString('yyyy-MM-dd')
      		if($freezeEndDate)
      		{
      			$freezeEndDate = $freezeEndDate.ToUniversalTime().ToString('yyyy-MM-dd')
      		}
      		$EventDetails."11" = $ActiveFreeze_Remediation_Event
      		$EventDetails."16" = "0"
      		$EventDetails."17" =$ReturnCodeDescription			
      		$EventDetails."14" = $freezeStartDate
      		$EventDetails."15" = $freezeEndDate
      		$Events = @(@{ "22.1" = $EventDetails })
      		Out-File $logFile -Append -InputObject "Active freeze rules in Remediation Before posting analytics"
      	}
      	Default 
      	{
      		$EventDetails."11" = $Generic_Remediation_Event_Name
      		$EventDetails."16" = "1"
      		$EventDetails."17" = $ReturnCodeDescription	
      		$Events =@(@{ "22.1" = $EventDetails })
      		Out-File $logFile -Append -InputObject "Default Remediation Failure Before posting analytics"
      	}
      	}
      	
      }
      
      $needReboot = $false # This value may be modified in the authentication policy
      $enableSureAdmin = $false # This value may be modified in the authentication policy
      $logFolder = "$($Env:LocalAppData)\HPConnect\Logs"
      $logFile = "502dad2c-71af-4e9b-b9a2-3a2222f85a02"
      $logPathDir = [System.IO.Path]::GetDirectoryName($logFolder)
      $exception = ""
      $biosSettingsErrorList = @{}
       enum PolicyRemediation
          {
                  FreezeRulesRemediation
                  PreRequisitesRemediation
                  BiosAuthenticationRemediation
                  BiosSettingsRemediation
                  BiosUpdatesRemediation
                  ClientDetailsRemediation
                  AllPoliciesCompleted
          }   
          
      try
      {  
        if ((Test-Path $logPathDir) -eq $false) {
          New-Item -ItemType Directory -Force -Path $logPathDir | Out-Null
        }
        if ((Test-Path -Path $logFolder) -eq $false) {
          New-Item -ItemType directory -Force -Path $logFolder | Out-Null
        }
        $date = Get-Date
        $logFile = $logFolder + "\" +  $logFile
        Out-File $logFile -Append -InputObject "====================== Remediation Script ======================"
        Out-File $logFile -Append -InputObject $date
        Out-File $logFile -Append -InputObject ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        Out-File $logFile -Append -InputObject $PSVersionTable 
      
        
         [PolicyRemediation]$Remediation =[PolicyRemediation]::PreRequisitesRemediation
        # Pre-requisites, i.e: HP-CMSL instalation
        function Get-LastestCMSLFromCatalog {
          Param([string]$catalog)
      
          $json = $catalog | ConvertFrom-Json
          $filter = $json."hp-cmsl" | Where-Object { $_.isLatest -eq $true }
          $sort = @($filter | Sort-Object -Descending {$_.version -As [version]})
          $sort[0]
      }
      
      # URI to get last HP-CMSL version approved for HP Connect
      $preReqUri = 'https://hpia.hpcloud.hp.com/downloads/cmsl/wl/hp-mem-client-prereq.json'
      $localDir = "$($Env:LocalAppData)\HPConnect\Tools"
      $sharedTools = "$($Env:ProgramFiles)\HPConnect"
      $maxTries = 3
      $triesInterval = 10
      
      # Download CMSL to the new location
      $updateSharedToolsLocation = $false
      if ([System.IO.Directory]::Exists("$localDir\hp-cmsl-wl")) {
          if (-not [System.IO.Directory]::Exists("$sharedTools\hp-cmsl-wl")) {
              Out-File $logFile -Append -InputObject "Moving HP-CMSL tool to Program Files"
              $updateSharedToolsLocation = $true
          }
      }
      
      # Read local metadata
      $localCatalog = "$localDir\hp-mem-client-prereq.json"
      $isLocalLocked = $false
      if ([System.IO.File]::Exists($localCatalog) -and [System.IO.Directory]::Exists("$sharedTools\hp-cmsl-wl")) {
          $local = Get-LastestCMSLFromCatalog(Get-Content -Path $localCatalog)
          $isLocalLocked = $local.isLocalLocked -eq $true
          Out-File $logFile -Append -InputObject "Current version of HP-CMSL-WL is $($local.version)"
      }
      else {
          $new = $true
          New-Item -ItemType Directory -Force -Path $localDir | Out-Null
          New-Item -ItemType Directory -Force -Path $sharedTools | Out-Null
      }
      
      if (-not $isLocalLocked) {
          $continueWithCurrent = $false
          # Download remote metadata
          $userAgent = "hpconnect-script"
          # Removing obsolete protocols SSL 3.0, TLS 1.0 and TLS 1.1
          [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]([System.Net.SecurityProtocolType].GetEnumNames() | Where-Object { $_ -ne "Ssl3" -and $_ -ne "Tls" -and $_ -ne "Tls11" })
          $tries = 0
          while ($tries -lt $maxTries) {
              try {
                  $data = Invoke-WebRequest -Uri $preReqUri -UserAgent $userAgent -UseBasicParsing -ErrorAction Stop -Verbose 4>> $logFile
                  break
              }
              catch {
                  Out-File $logFile -Append -InputObject "Failed to retrieve HP-CMSL-WL catalog ($($tries+1)/$maxTries) : $($_.Exception.Message)"
                  if ($tries -lt $maxTries-1) {
                      if ($tries -lt $maxTries-1) {
                          # Wait some interval between tries
                          Start-Sleep -Seconds $triesInterval
                      }
                  }
                  else {
                      if ($new -and -not $updateSharedToolsLocation) {
                          throw "Unable to retrieve HP-CMSL-WL catalog"
                      }
                      else {
                          Out-File $logFile -Append -InputObject "Unable to retrieve HP-CMSL-WL catalog. The script will continue with the local version"
                          $continueWithCurrent = $true
                      }
                  }
              }
              $tries = $tries + 1
          }
      
          if (-not $continueWithCurrent) {
              $catalog = [System.IO.StreamReader]::new($data.RawContentStream).ReadToEnd()
              $remote = Get-LastestCMSLFromCatalog($catalog)
              
              if ($new -or [Version] $remote.version -gt [Version] $local.version) {
                  # Download and unpack new version
                  $tmpDir = "$env:TEMP"
                  $tmpFile = "$tmpDir\h.exe"
                  Remove-Item -Path $tmpFile -Force -ErrorAction Ignore
                  $tries = 0
                  Out-File $logFile -Append -InputObject "Download HP-CMSL-WL $($remote.version) from $($remote.url)"
                  while ($tries -lt $maxTries) {
                      try {
                          Invoke-WebRequest -Uri $remote.url -UserAgent $userAgent -UseBasicParsing -ErrorAction Stop -OutFile $tmpFile -Verbose 4>> $logFile
                          break
                      }
                      catch {
                          Out-File $logFile -Append -InputObject "Failed to retrieve HP-CMSL-WL installer ($($tries+1)/$maxTries) : $($_.Exception.Message)"
                          if ($tries -lt $maxTries-1) {
                              if ($tries -lt $maxTries-1) {
                                  # Wait some interval between tries
                                  Start-Sleep -Seconds $triesInterval
                              }
                          }
                          else {
                              if ($new -and -not $updateSharedToolsLocation) {
                                  throw "Unable to download the HP-CMSL-WL installer"
                              }
                              else {
                                  Out-File $logFile -Append -InputObject "Unable to download the HP-CMSL-WL installer. The script will continue with the local version"
                                  $continueWithCurrent = $true
                              }
                          }
                      }
                      $tries = $tries + 1
                  }
      
                  if (-not $continueWithCurrent) {
                      if (-not $new -and -not $updateSharedToolsLocation) {
                          Out-File $logFile -Append -InputObject "Remove current HP-CMSL-WL $($local.version) from $sharedTools\hp-cmsl-wl"
                          Remove-Item -Force -Path "$sharedTools\hp-cmsl-wl" -Recurse
                      }
              
                      if ($updateSharedToolsLocation) {
                          Out-File $logFile -Append -InputObject "Remove HP-CMSL from previous location $localDir\hp-cmsl-wl"
                          Remove-Item -Force -Path "$localDir\hp-cmsl-wl" -Recurse
                      }
              
                      Out-File $logFile -Append -InputObject "Unpack CMSL from $tmpFile to $sharedTools\hp-cmsl-wl"
                      # Wait for the CMSL extraction to complete
                      $arguments = '/LOG="', $tmpDir, '\hp-cmsl-wl.log" /VERYSILENT /SILENT /SP- /NORESTART /UnpackOnly="True" /DestDir="', $sharedTools, '\hp-cmsl-wl"' -Join ''
                      Start-Process -Wait -LoadUserProfile -FilePath $tmpFile -ArgumentList $arguments
                      Move-Item -Path "$tmpDir\hp-cmsl-wl.log" -Destination "$logFolder\hp-cmsl-wl" -Force -ErrorAction Stop
              
                      # Update local metadata
                      $catalog | Set-Content -Path $localCatalog -Force
              
                      # Delete installer
                      Remove-Item -Path $tmpFile -Force -ErrorAction Ignore
                  }
              }
          }
      
          if ($continueWithCurrent) {
              if ($updateSharedToolsLocation) {
                  $sharedTools = $localDir
              }
          }
      }
      else {
          Out-File $logFile -Append -InputObject "Using a local locked version of HP-CMSL-WL"
      }
      
      # Import CMSL modules from local folder
      Out-File $logFile -Append -InputObject "Import CMSL from $sharedTools\hp-cmsl-wl"
      $modules = @(
          'HP.Private',
          'HP.Utility',
          'HP.ClientManagement',
          'HP.Firmware',
          'HP.Notifications',
          'HP.Retail',
          'HP.Softpaq',
          'HP.Sinks',
          'HP.Repo',
          'HP.Consent',
          'HP.SmartExperiences'
      )
      foreach ($m in $modules) {
          if (Get-Module -Name $m) { Remove-Module -Force $m }
      }
      foreach ($m in $modules) {
          try {
              Import-Module -Force "$sharedTools\hp-cmsl-wl\modules\$m\$m.psd1" -ErrorAction Stop
          }
          catch {
              $exception = $_.Exception
              Out-File $logFile -Append -InputObject "Failed to import module $m"
              # Script will try to download and import CMSL again on the next execution
              Remove-Item "$sharedTools\hp-cmsl-wl" -Recurse -Force -ErrorAction Stop
              Remove-Item "$localCatalog" -Force -ErrorAction Stop
              throw $exception
          }
      }
        
        #Gather client device details for Posting Analytics
        [PolicyRemediation]$Remediation =[PolicyRemediation]::ClientDetailsRemediation
        	# function for compression
      	function Compress-Data 
      	{
      		<#
      		.Synopsis
      			Compresses data
      		.Description
      			Compresses data into a GZipStream
      		.Link
      			Expand-Data
      		.Link
      			http://msdn.microsoft.com/en-us/library/system.io.compression.gzipstream.aspx
      		.Example
      			$rawData = (Get-Command | Select-Object -ExpandProperty Name | Out-String)
      			$originalSize = $rawData.Length
      			$compressed = Compress-Data $rawData -As Byte
      			"$($compressed.Length / $originalSize)% Smaller [ Compressed size $($compressed.Length / 1kb)kb : Original Size $($originalSize /1kb)kb] "
      			Expand-Data -BinaryData $compressed
      		#>
      		[OutputType([String],[byte])]
      		[CmdletBinding(DefaultParameterSetName='String')]
      		param(
      		# A string to compress
      		[Parameter(ParameterSetName='String',
      			Position=0,
      			Mandatory=$true,
      			ValueFromPipelineByPropertyName=$true)]
      		[string]$String,
          
      		# A byte array to compress.
      		[Parameter(ParameterSetName='Data',
      			Position=0,
      			Mandatory=$true,
      			ValueFromPipelineByPropertyName=$true)]
      		[Byte[]]$Data,
          
      		# Determine how the data is returned.
      		# If set to byte, the data will be returned as a byte array. If set to string, it will be returned as a string.
      		[ValidateSet('String','Byte')]
      		[String]$As = 'string'   
      		)
          
      		process {
                 
      			if ($psCmdlet.ParameterSetName -eq 'String') {
      				$Data= foreach ($c in $string.ToCharArray()) {
      					$c -as [Byte]
      				}            
      			}
              
      			#region Compress Data
      			$ms = New-Object IO.MemoryStream                
      			$cs = New-Object System.IO.Compression.GZipStream ($ms, [Io.Compression.CompressionMode]"Compress")
      			$cs.Write($Data, 0, $Data.Length)
      			$cs.Close()
      			#endregion Compress Data
              
      			#region Output CompressedData
      			if ($as -eq 'Byte') {
      				$ms.ToArray()
                  
      			} elseif ($as -eq 'string') {
      				[Convert]::ToBase64String($ms.ToArray())
      			}
      			$ms.Close()
      			#endregion Output CompressedData        
      		}
      	}
      		
      	# Params
      	$UOID = '6b101653-1670-471e-bd47-11f5e9993246'	
      
         # Prepare OS and device details for posting Client analytics
      	$HPCmslInfo = (Get-HPCMSLEnvironment)
      	$OSName = $HPCmslInfo.OsName
      	$OSBuildNumber =$HPCmslInfo.OsBuildNumber
      	$OSVersion =$HPCmslInfo.OsVersion
      	$OSArchitecture = $HPCmslInfo.OSArchitecture	
      	$OSDisplayVersion =$HPCmslInfo.OsVer	
      	$PowerShellBitness = $HPCmslInfo.Bitness	
      	$ProductId = $HPCmslInfo.CsSystemSKUNumber
      	$SerialNumber = Get-HPDeviceSerialNumber
      	$DeviceUUID = Get-HPDeviceUUID
      	$CmslVersion =$local.version
      	$SMBIOSVersion = Get-HPBIOSSettingValue -Name "System BIOS Version"	
      	$PlatformName = Get-HPBIOSSettingValue -Name "Product Name"
      	
      	# get powershell version
      	$PSVersion = $HPCmslInfo.PSVersion
      	$Major = $PSVersion.Major
      	$Minor = $PSVersion.Minor
      	$Build = $PSVersion.Build
      	$Revision = $PSVersion.Revision
      	$PowershellVersion = ($Major,$Minor,$Build,$Revision) -Join "."
      	
      	# Get Unit details 
      	$OS = Get-CimInstance -ClassName Win32_OperatingSystem
      	$Culture = [System.Globalization.CultureInfo]::GetCultures("SpecificCultures") | Where {$_.LCID -eq $OS.OSLanguage}
      	$RegionInfo = New-Object System.Globalization.RegionInfo $Culture.Name
      	$CountryCode = $RegionInfo.TwoLetterISORegionName
      	$OSLanguage =$OS.OSLanguage
      	$OSDetail = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")
      	$OSReleaseId =$OSDetail.ReleaseId
      	$UnitModel =Get-HPDeviceModel
      	$HPProductID=Get-HPDeviceProductID
      	$UnitPlatformID = Get-HPDeviceProductID
      
      	#TODO Confirm below 2 param details :
      	$UnitCollectionID =  [guid]::NewGuid()
      	$SessionID = [guid]::NewGuid()
      
      	# 2022-04-10T14:59:30-05:00
      	$Date = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmss')
      	$Version = "1.0"
      	$Provider = "HP Connect"
      	$ProviderVersion = "v1.0"
      	$EventCategory = "Usage"
      	$EventType = "Status"	
      
      	$ReturnCodeDescription =""
      	$ReturnCode = 0
      
      	# initialize unit
      	$Unit =@{
              V =$Version
      	    DT= $Date
      	    "0" = $SerialNumber
      		"1" = $ProductId
      	    "2" = $DeviceUUID
      	    "3" = $CountryCode
      	    "4" = $Provider
      	    "5" = $ProviderVersion
      	    "6" = $UnitModel
      	    "7" = $UnitPlatformID
      	    "8" = $UnitCollectionID	
            }	
      	
      	$EventDetails = New-Object -TypeName PsObject -Property @{
      	     DT = $Date
      		"1" = $UOID
      		"2" = $OSVersion
      		"3" = $PowershellVersion
      		"4" = $CmslVersion
      		"5" = $PlatformName
      		"6" = $PowerShellBitness
      		"7" = $SMBIOSVersion
      		"8" = $EventCategory
      		"9" = $EventType
      		"10" = $Provider
      		"11" = ""
      		"12" = "N/A"
      		"13" = "N/A"
      		"14" = $freezeStartDate
      		"15" = $freezeEndDate
      		"16" = $ReturnCode
      		"17" = $ReturnCodeDescription
      		"18" = $OSName
      		"19" = $OSBuildNumber
      		"20" = $OSArchitecture		
      		"21" = $OSLanguage
      		"22" = $OSDisplayVersion
      		"23" = $OSReleaseId
      	}	
      
         [PolicyRemediation]$Remediation =[PolicyRemediation]::FreezeRulesRemediation
        # Process freeze rules (if any)
        
      }
      catch {
        Out-File $logFile -Append -InputObject "Pre-Requisite failed: $($_.Exception.Message)"
        $exception = $_.Exception.Message
        ClientRemediation($exception)
        # If a pre-requisite fails
        throw $_.Exception
      }
      
      try {
        # Replace this with combined & ordered remediation scripts from various policy types   
        # Authentication policy script
         [PolicyRemediation]$Remediation =[PolicyRemediation]::BiosAuthenticationRemediation
        
      
        # BIOS setting policy scripts
        # Skip BIOS setting policy execution if a reboot is needed and the authentication policy is for enabling Sure Admin.
        # When using Sure Admin authentication mode all the setting changes must be signed, so we have to wait for the Secure Platform provisioning process to finish before to apply the setting changes.
        # The Sure Admin is only enabled after the reboot since it requires secure platform provisioning and this is only completed after device reboots.
        if (-not ($needReboot -and $enableSureAdmin)) {
          [PolicyRemediation]$Remediation =[PolicyRemediation]::BiosSettingsRemediation     
          function UpdateBiosSettingsErrors {
             if($biosSettingsErrorList[$item.Key]) {
              $biosSettingsErrorList[$item.Key] = $errMessage
             }   
             else {
              $biosSettingsErrorList.Add($item.Key,$errMessage)   
             }                  
      }
      
      function ProcessSureAdminSettings{
          Param(
                  $selectedPayload,
                  $isFallBackValues
              ) 
              
              $payload = $selectedPayload[0].Value | ConvertFrom-Json   
              $payloadData = [System.Text.Encoding]::ASCII.GetString($payload.Data)
              $settings = $payloadData | ConvertFrom-Json
              #Add settings from generic policy to settings table        
              foreach ($s in $settings) {
                      $payload.purpose = 'hp:sureadmin:biossetting'
                      [SureAdminSetting]$singleSetting = New-Object -TypeName SureAdminSetting
                      $singleSetting.Name = $s.Name
                      $singleSetting.Value = $s.Value
                      $singleSetting.AuthString = $s.AuthString
                      $singleStringJson = $singleSetting | ConvertTo-Json
                      $payload.data = [System.Text.Encoding]::ASCII.GetBytes($singleStringJson)    
                      $singleSettingPayload = $payload | ConvertTo-Json -Compress
                      if($isFallBackValues -eq $true) {
      				    $key = $s.Name + "_" + $s.Value
                          if($sureAdminFallbackSettingsTable[ $key]) {
                              $sureAdminFallbackSettingsTable[ $key] = $singleSettingPayload
                          }
                          else {                
                              $sureAdminFallbackSettingsTable.Add($key, $singleSettingPayload)
                          }
                      }
                      else
                      {
                          if($sureAdminSettingsTable[$s.Name]) {
                              $sureAdminSettingsTable[$s.Name] = $singleSettingPayload
                          }
                          else {
                              $sureAdminSettingsTable.Add($s.Name, $singleSettingPayload)
                          }
                      }
              }                               
      }
      
      $password = ''
      $settingsPayloadsTable = @{}
      
      # Array of bios settings hash table
      $settingsTable = @{'generic'=@{'Configure Legacy Support and Secure Boot'='Legacy Support Disable and Secure Boot Enable';'Legacy Support'='Disable';'Secure Boot'='Enable';'TPM Device'='Available';'TPM State'='Enable';};}
      $sureadminEnabled = $false
      $settingsFallbackTable =[ordered]@{}
      $settingsFallbackTable = @{'Configure Legacy Support and Secure Boot'='';'Legacy Support'='';'Secure Boot'='';'TPM Device'='';'TPM State'='';};
      $settingsPayloadsFallbackTable = @{}
      $biosSettings = @{}
      
      #Parse settings from plain settings table
      # Get the generic BIOS settings
      $selectedGenericRecord = @($settingsTable.GetEnumerator() | Where-Object -Property Name -Match "generic")
      if ($selectedGenericRecord.Count -eq 0)
      {
          Out-File $logFile -Append -InputObject "No generic settings applicable"
      }
      if ($selectedGenericRecord.Count -gt 1) {
          Out-File $logFile -Append -InputObject "Multiple generic settings entries, using the first"
      }
      if ($selectedGenericRecord.Count -gt 0) {
          $biosSettings = $selectedGenericRecord[0].Value
          Out-File $logFile -Append -InputObject "Generic BIOS settings selected"
      }
      
      $productName = Get-HPBIOSSettingValue -Name "Product Name"
      $baseboardId = Get-HPBIOSSettingValue -Name "System Board ID"
      
      # Get the BIOS settings for this specific system ID
      $selectedSpecificRecord = @($settingsTable.GetEnumerator() | Where-Object -Property Name -Match "$($baseboardId)\|(.*)")
      # Table for Sure Admin Bios settings and Sure Admin Fallback settings
      $sureAdminSettingsTable = @{}
      $sureAdminFallbackSettingsTable = @{}
      if ($selectedSpecificRecord.Count -eq 0)
      {
          Out-File $logFile -Append -InputObject "No specific settings applicable for platform: $productName, $baseboardId"
      }
      
      if ($selectedSpecificRecord.Count -gt 1) {
          Out-File $logFile -Append -InputObject "Multiple entries for the same system id ($baseboardId), using the first one"
      }
      
      if ($selectedSpecificRecord.Count -gt 0) {
          $selectedSpecificRecord[0].Value.keys | ForEach-Object {$biosSettings[$_] = $selectedSpecificRecord[0].Value[$_]}
          Out-File $logFile -Append -InputObject "Specific BIOS settings selected"
      }
      
          #Parse settings from sure admin payload
      if ($sureadminEnabled -eq $true) {
              $selectedGenericPayload = @($settingsPayloadsTable.GetEnumerator() | Where-Object -Property Name -Match "generic")
              if ($selectedGenericPayload.Count -eq 0) {
                 Out-File $logFile -Append -InputObject "No generic settings payload applicable"
              }
              if ($selectedGenericPayload.Count -gt 1) {
                 Out-File $logFile -Append -InputObject "Multiple generic settings payloads entries, using the first one"
              }
              if ($selectedGenericPayload.Count -gt 0) {
               ProcessSureAdminSettings -selectedPayload $selectedGenericPayload -isFallBackValues $false         
              }
      
              # Parse fallback settings from sure admin fallback payload
              $selectedGenericFallbackPayload = @($settingsPayloadsFallbackTable.GetEnumerator() | Where-Object -Property Name -Match "generic")
              if ($selectedGenericFallbackPayload.Count -eq 0) {
                 Out-File $logFile -Append -InputObject "No generic fallback settings payload applicable"
              }
              if ($selectedGenericFallbackPayload.Count -gt 1) {
                 Out-File $logFile -Append -InputObject "Multiple generic settings payloads entries, using the first one"
              }
              if ($selectedGenericFallbackPayload.Count -gt 0) {
                  ProcessSureAdminSettings -selectedPayload $selectedGenericFallbackPayload -isFallBackValues $true
              }
      
              #Specific settings parsing
              $selectedSpecificPayload = @($settingsPayloadsTable.GetEnumerator() | Where-Object -Property Name -Match "$($baseboardId)\|(.*)")
              if ($selectedSpecificPayload.Count -eq 0) {
                 Out-File $logFile -Append -InputObject "No specific settings payload applicable"
              }  
              if ($selectedSpecificPayload.Count -gt 0) {
                  #Add/Overwrite settings table with data from specific settings
                  ProcessSureAdminSettings -selectedPayload $selectedSpecificPayload -isFallBackValues $false
              }
          }
      
      if ($biosSettings.Count -gt 0) {
          $errMessage =""
           $SettingList = Get-WmiObject -Namespace root\HP\InstrumentedBIOS -Class HP_BIOSEnumeration   
          foreach ($item in $biossettings.GetEnumerator()) {
              $PossibleValues = ($SettingList | Where-Object Name -eq $item.Key).PossibleValues   
               $valueVariationMatch = $false
              try {
                  $currentSettingValue = Get-HPBIOSSettingValue -Name $item.Key
                  # test against all value variations
                  foreach ($v in $item.Value) {
                      if ($item.Key -eq 'UEFI Boot Order') {
                          # Policy contains the complete list of devices including network
                          # In local system we compare only the order of the intersection
                          $v = ((($v) -Split ',') | Where-Object { (($currentSettingValue) -Split ',') -Contains $_ }) -Join ','
                      }
                       if ($currentSettingValue -eq $v) {
                          $valueVariationMatch = $true
                          break
                      }
                  }            
                    # This will be used in the final combined script that gets generated for bios settings/update/etc.
                    if (-not $valueVariationMatch) {
                      foreach ($v in $item.Value) {
                          try{
                               if ($sureadminEnabled -eq $false) {                        
                                  Set-HPBIOSSettingValue -Name $item.Key -Value $v -Password $password *>> $logFile
                                  if($biosSettingsErrorList[$item.Key]) {
                                  $biosSettingsErrorList.Remove($item.Key)
                                  }                                   
                                  $needReboot = $true
                                  $valueVariationMatch = $true
                                  break                            
                                  }                                
                               else {
                              # Sure Admin is on and at least one setting value variation has to be updated                        
                                  $sureAdminSettingsTable[$item.Key] | Set-HPSecurePlatformPayload *>> $logFile
                                   if($biosSettingsErrorList[$item.Key])  {
                                      $biosSettingsErrorList.Remove($item.Key)
                                      }          
                                  $needReboot = $true
                                  $valueVariationMatch = $true
                                  break
                              }  
                          }
                          catch {
                             $errMessage = "Failed to set BIOS setting: $($item.Key) to desired value variation, $($_.Exception.Message). Possible dependency condition not met."
                             UpdateBiosSettingsErrors
                             Out-File $logFile -Append -InputObject $errMessage
                          }     
                     }                    
                   }
      
                   #Try to set fallback values if desired value could not set for global policies only.
                   if( -not $valueVariationMatch) {
                     if ($settingsFallbackTable[$item.Key]) {
      			    $fallbackValueList = [ordered]@{}
                      $fallbackValueList = $settingsFallbackTable[$item.Key]
      				foreach ($v in $fallbackValueList) {
                         if($v -ne ""){
                                 try {
                                      if ($sureadminEnabled -eq $false){                        
                                          Set-HPBIOSSettingValue -Name $item.Key -Value $v -Password $password *>> $logFile
                                          if($biosSettingsErrorList[$item.Key]) {
                                          $biosSettingsErrorList.Remove($item.Key)
                                          }                                   
                                          $needReboot = $true
                                          break                            
                                          }                                
                                      else{
                                      # Sure Admin is on and at least one setting value variation has to be updated
                                          $keyName = $item.Key + "_" + $v
                                          $sureAdminFallbackSettingsTable[$keyName] | Set-HPSecurePlatformPayload *>> $logFile
                                           if($biosSettingsErrorList[$item.Key])  {
                                              $biosSettingsErrorList.Remove($item.Key)
                                              }          
                                          $needReboot = $true
                                          break
                                      }  
                                  }
                                 catch {
                                     $errMessage = "Failed to set BIOS setting: $($item.Key) to fallback value, $($_.Exception.Message). Possible dependency condition not met."
                                     UpdateBiosSettingsErrors
                                     Out-File $logFile -Append -InputObject $errMessage
                                  }    
                         }
                         else{
                          Out-File $logFile -Append -InputObject "BIOS setting: $($item.Key) doesnt have any fallback values defined for this setting."
                         }
                        }
                       }
                     else {
                          Out-File $logFile -Append -InputObject "BIOS setting: $($item.Key) doesnt have any fallback values defined for the setting."
                       }
                   }
              }  
              catch [System.Management.Automation.ItemNotFoundException] {
                  # Ignore setting doesn't exist case
                  Out-File $logFile -Append -InputObject "Skipping setting that does not exist on this platform: $($item.Key)"
              }
              catch {
                  $errMessage = "Failed to set BIOS setting: $($item.Key), $($_.Exception.Message)."
                  Out-File $logFile -Append -InputObject $errMessage
                  UpdateBiosSettingsErrors      
              }        
          }
      }
      
      
          # Log errors without stoping the execution
          if($biosSettingsErrorList.count -gt 0)
          {
              Out-File $logFile -Append -InputObject "BIOS settings exception: Failure for one or more settings" 
              $exception = "BiosSettings Remediation Failure for one or more settings"
              ClientRemediation($exception)
          }
        }
      }
      catch {
        Out-File $logFile -Append -InputObject "BIOS Authentication/Setting exception: $($_.Exception.Message)"
        $exception = $_.Exception.Message
        ClientRemediation($exception)
        $throw = $_.Exception
      }
      
      # BIOS update is authentication agnostic, so the scripts run even if an exception was raised in the previous phases, which are Authentication and Setting
      try {
        # BIOS update policy scripts
        [PolicyRemediation]$Remediation =[PolicyRemediation]::BiosUpdatesRemediation
        
      }
      catch {
        Out-File $logFile -Append -InputObject "BIOS update exception: $($_.Exception.Message)" 
        $exception = $_.Exception.Message
         ClientRemediation($exception)
         # Log exceptions without stoping the execution because a notification may be required from previous phases even if an exception occur on the BIOS update
        $throw = $_.Exception
      }
      
      [PolicyRemediation]$Remediation =[PolicyRemediation]::AllPoliciesCompleted  
      ClientRemediation($exception)
      
      if ($needReboot) {
        Out-File $logFile -Append -InputObject "Invoking the toast notification to ask user to reboot"
        gpupdate /wait:0 /force /target:computer | Out-File $logFile -Append
        Invoke-RebootNotification -Title 'PC Reboot Required' -Message 'Your device administrator has applied a policy or update that requires a reboot. Dismiss to apply policy updates on your next PC reboot.'
      }
      
      if ($throw) {
        throw $throw
      }
      
       # intune health script , 0 means success 1 means failure    
          if($biosSettingsErrorList.Count -gt 0)
          {      
             $biosSettingsErrorList.GetEnumerator() | ForEach-Object{
              Write-Error "Bios Setting : $($_.key) : Error : $($_.value)"
             }    
             #exit 1
          }
          else
          {
              Write-Output ""
              #exit 0
          }
      
      
}

function Main {
    try {
        Check-Compliance
        $remediationNeeded = $false
    } catch {
        Write-Error "Detection failed: $($_.Exception.Message)"
        $remediationNeeded = $true
    }

    if ($remediationNeeded) {
        try {
            Remediate-NonCompliance
            Write-Output "Remediation successful"
        } catch {
            Write-Error "Remediation failed: $($_.Exception.Message)"
        }
    } else {
        Write-Output "BIOS settings are compliant"
    }
}

Main