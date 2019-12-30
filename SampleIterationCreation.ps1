$org = "YOURORG" #Your devops org (e.g. https://yourorg.visualstudio.com/)
$projectName = "YOURPROJECT" #Your Project
$pat = "YOUR PERSONAL ACCESS TOKEN" #Your personal access token with Project admin rights
$sprintLength = "14" #Length of Sprint in Days
$startDate = Get-Date -Date "12/30/2019" #First day of Release Iteration
$endDate = Get-Date -Date "12/31/2020" #Last day of Release Iteration
$releaseName = "Release 1" #Name of release
$sprintPrefix = "Sprint " #How your sprints will be named (note the space after the sprint name)
$zeroPaddingLength = "3" #e.g. Sprint 001 (3), Sprint 01 (2)

$listurl = "https://dev.azure.com/$org/$projectName/_apis/wit/classificationnodes/Iterations?api-version=5.0"
$encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$pat")) #base64 encoded access token

$curDate = $startDate
$curLoop = 0
$children = @()

while ($curDate.AddDays($sprintLength - 1) -le $endDate) {
    $children += @{
        name       =  $sprintPrefix + $curLoop.ToString().PadLeft($zeroPaddingLength, "0");
        attributes = @{
            startDate  = $curDate;
            finishDate = $curDate.AddDays($sprintLength - 1);
        };
    }
    $curDate = $curDate.AddDays($sprintLength)
    $curLoop++
}

$body = ConvertTo-Json -Depth 3 @{
    name       = $releaseName;
    attributes = @{
        startDate  = $startDate;
        finishDate = $endDate;
    };
    children = $children;
    hasChildren = $true;
}

$resp = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat" } -Body $body -ContentType "application/json" -Method Post
Write-Output $resp