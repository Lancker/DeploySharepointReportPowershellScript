DeploySharepointReportPowershellScript
======================================

Deploy Sharepoint  Reports Powershell Script
This PowerShell Script is used for deploy Sharepoint reports.I'v tested it under sharepoint 2013 & SqlServer 2012.Plz adjust it if want to use it in other verions.
本PowerShell脚本是用于部署Sharepoint报表。我已经在Sharepoint 2013 & SqlServer 2012的环境下测试过脚本。如果你在别的环境下使用，请适当调整脚本。

Version 1.0

This verison base on lot's of ref from Internet.I made it from others.U can find ref links from my Blog.I void use ReportService2010.asmx in this script.More detail plz take a visit in http://www.zhongdaiqi.com/deploy-reports-powershell-sharepoint-2013/
初始版本参考了互联网上各种资料，在前人的基础上做了调整。避免了使用ReportService2010.asmx，详细的脚本思路请参考我的博文：
http://www.zhongdaiqi.com/deploy-reports-powershell-sharepoint-2013/

Bug:
1.No temp files,only the first running is correct,because the report is modified.
脚本未使用临时文件，目前执行后会污染原始报表文件，二次执行报表中的共享数据集会乱掉，但是数据源不会。


Ref:
http://sharepoint.stackexchange.com/questions/47652/programmatically-set-data-source-link-for-ssrs-report-files
http://msdn.microsoft.com/en-us/library/reportservice2010.reportingservice2010.setitemdatasources.aspx
http://social.msdn.microsoft.com/Forums/zh-TW/b8535214-0f80-4ff6-81c2-dad5bb656b64/ssrs-sharepoint-foundation-2010-integration-deployment-query?forum=sqlreportingservices
