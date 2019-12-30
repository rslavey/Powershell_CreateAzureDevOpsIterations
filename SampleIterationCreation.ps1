$tenantName = "YOURTENANT" #Your devops tenant (e.g. https://yourtenant.visualstudio.com/)
$pat = "YOUR PERSONAL ACCESS TOKEN" #Your personal access token with Project admin rights
$sprintLength = "14" #Length of Sprint in Days
$startDate = Get-Date -Date "12/30/2019" #First day of Release Iteration
$endDate = Get-Date -Date "12/31/2020" #Last day of Release Iteration
$releaseName = "Release 1" #Name of release
$sprintPrefix = "Sprint " #How your sprints will be named (note the space after the sprint name)
$zeroPaddingLength = "3" #e.g. Sprint 001 (3), Sprint 01 (2)
$parentId = "ROOT ITERATION GUID" #GUID of root project iteration
$projectId = "PROJECT GUID" #GUID of project

$listurl = 'https://' + $tenantName + '.visualstudio.com/' + $projectId + '/_admin/_Areas/CreateClassificationNode?useApiUrl=true&__v=5'
$encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$pat")) #base64 encoded access token

#Create New Release
$body = ConvertTo-Json @{
    operationData        = '{"NodeId":"00000000-0000-0000-0000-000000000000","NodeName":"' + $releaseName + '","ParentId":"' + $parentId + '","IterationStartDate":"' + $startDate + '","IterationEndDate":"' + $endDate + '"}';
    syncWorkItemTracking = $false
}

$resp = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat" } -Body $body -ContentType "application/json" -Method Post

#If Create New Release Successful, Create Iterations
if ($resp.success) {
    $newReleaseId = $resp.node.id
    Write-Output "New Release GUID: $newReleaseId"

    $curDate = $startDate
    $curLoop = 0

    while ($curDate.AddDays($sprintLength - 1) -le $endDate) {
        $body = ConvertTo-Json @{
            operationData        = '{"NodeId":"00000000-0000-0000-0000-000000000000",' +
            '"NodeName":"' + $sprintPrefix + $curLoop.ToString().PadLeft($zeroPaddingLength, "0") + '",' +
            '"ParentId":"' + $newReleaseId + '",' + 
            '"IterationStartDate":"' + $curDate + '",' +
            '"IterationEndDate":"' + $curDate.AddDays($sprintLength - 1) + '"}';
            syncWorkItemTracking = $false
        }

        $resp = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat" } -Body $body -ContentType "application/json" -Method Post

        if (!$resp.success) {
            throw "Error creating Iteration " + $sprintPrefix + $curLoop.ToString().PadLeft($zeroPaddingLength, "0") + ": " + $resp.message
        }

        $curDate = $curDate.AddDays($sprintLength)
        $curLoop++
    }
}
else {
    Write-Output "Error creating new Release: " + $resp.message
}
