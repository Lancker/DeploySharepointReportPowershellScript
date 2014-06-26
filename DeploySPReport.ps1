# Define variables
$siteCollectionURL = "http://[spsite]"
$sourceFolder = "C:\report"
$targetRptLib = $siteCollectionURL+"/Report"
$targetDCL    = $siteCollectionURL+"/DataConnection"
$targetDSL	  = $siteCollectionURL+"/DataSet"
$targetDataSourceName	  = $targetDCL+"/[datasourceName].rsds"
$rsProxyEndpt2006 = $siteCollectionURL+"/_vti_bin/ReportServer/ReportService2006.asmx"



function publish-DataSource ([string] $dsReference)
{
	#Load the data source Xml 
	[xml] $DSXml = Get-Content ($dsReference);	
	#Initialize a DataSourceDefinition object
	[DataSourceDefinition] $dsDefinition = New-Object DataSourceDefinition
	#Initialize a DataSource object
	[DataSource] $dSource = New-Object DataSource
	$dSource.Item = $dsDefinition
	#Read the settings from XML and populate related props
	$dsDefinition.Extension = $DSXml.RptDataSource.ConnectionProperties.Extension
	$dsDefinition.ConnectString = $DSXml.RptDataSource.ConnectionProperties.ConnectString
	$dsDefinition.ImpersonateUserSpecified = $true
	$dsDefinition.Prompt = $null
	$dsDefinition.WindowsCredentials = $true	
	$dsDefinition.CredentialRetrieval = [CredentialRetrievalEnum]::Integrated
	$dSource.Name = $DSXml.RptDataSource.Name
	$dsFileName = [String]::Concat($DSXml.RptDataSource.Name.Trim(),".rsds")
	$rsdsAbsoluteUrl = [string]::Concat($targetDCL.TrimEnd("/"),"/",$dsFileName)
	#Publish the data source to the data connection library
	$void = $rs06.CreateDataSource($dsFileName, $targetDCL, $true, $dsDefinition, $null)  
	WRITE-HOST -FOREGROUND Yellow 'Successfully converted data source:' $dsFileName
}

function publish-DataSet ([string] $dsReference){
	#Load the data source Xml 
	[xml] $DSXml = Get-Content ($dsReference); 
	$file = Get-Childitem ($dsReference);
	
	$site=Get-SpSite $siteCollectionURL
	$web=$site.RootWeb
	$rsdFolder = $web.GetFolder($targetDSL)

	$desturl = $targetDSL+"/"+$file.Name
	#Write-Host "Name is: " $file.Name

	(Get-Content $dsReference) | % {$_ -replace "<DataSourceReference>.*?</DataSourceReference>","<DataSourceReference>$targetDataSourceName</DataSourceReference>"} | Set-Content -path $dsReference
	
	#Write-Host "Processing Completed"
	$rsdFile=$web.GetFile($desturl)
	$fileCheckedOut = "N"
	if($rsdFile.Exists){
	$rsdFile.CheckOut();
	$fileCheckedOut = "Y"
	}
	$stream = [IO.File]::OpenRead($dsReference)
	$resultingfile =$rsdFolder.files.Add($desturl,$stream,$true)
	$stream.close()

	if($fileCheckedOut -eq "Y")
	{
	$rsdFile.CheckIn("Deployment Script")
	}
	$rsdFile.Update()    

	WRITE-HOST 'Successfully Deployed Data Set:' $file.Name
	}

function publish-Report ([string] $reportReference){
	#Load the data source Xml 
	[xml] $DSXml = Get-Content ($reportReference); 
	$file = Get-Childitem ($reportReference);
	
	$site=Get-SpSite $siteCollectionURL
	$web=$site.RootWeb
	$rptFolder = $web.GetFolder($targetRptLib)

	$desturl = $targetRptLib+"/"+$file.Name
	#Write-Host "Name is: " $file.Name

	(Get-Content $reportReference) | % {$_ -replace "<DataSourceReference>.*?</DataSourceReference>","<DataSourceReference>$targetDataSourceName</DataSourceReference>"}| % {$_ -replace "<SharedDataSetReference>","<SharedDataSetReference>$targetDSL/"}| % {$_ -replace "</SharedDataSetReference>",".rsd</SharedDataSetReference>"}| Set-Content -Encoding UTF8  -path $reportReference
	
	#Write-Host "Processing Completed"
	$reportFile=$web.GetFile($desturl)
	$fileCheckedOut = "N"
	if($reportFile.Exists){
	$reportFile.CheckOut();
	$fileCheckedOut = "Y"
	}
	$stream = [IO.File]::OpenRead($reportReference)
	$resultingfile =$rptFolder.files.Add($desturl,$stream,$true)
	$stream.close()

	if($fileCheckedOut -eq "Y")
	{
	$reportFile.CheckIn("Deployment Script")
	}
	$reportFile.Update()    

	WRITE-HOST 'Successfully Deployed Data Set:' $file.Name
	}


$void=[Reflection.Assembly]::LoadFrom("$pwd\ReportingService2006.dll")
$rs06 = New-Object ReportingService2006
$rs06.Url = $rsProxyEndpt2006;
$rs06.Credentials=[System.Net.CredentialCache]::DefaultCredentials
$sourceFolder = $sourceFolder

#Publish Data sources 
[Object[]] $dataSourcesToPublish = [System.IO.Directory]::GetFiles($sourceFolder, "*.rds");
$dataSourcesToPublish | % { publish-DataSource $_ };

#Publish Data Sets 
[Object[]] $dataSetsToPublish = [System.IO.Directory]::GetFiles($sourceFolder, "*.rsd");
$dataSetsToPublish | % { publish-DataSet $_ };

#Publish Report 
[Object[]] $reportsToPublish = [System.IO.Directory]::GetFiles($sourceFolder, "*.rdl");
$reportsToPublish | % { publish-Report $_ };
