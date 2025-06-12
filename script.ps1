$RoadmapURL = "https://www.microsoft.com/releasecommunications/api/v1/m365"
$Result = Invoke-RestMethod -Method Get -Uri $RoadmapURL

# Filter results for items with "Copilot" in the title and status "Rolling Out"
$FilteredResult = $Result | Where-Object { $_.title -like "*Copilot*" -and $_.status -eq "Rolling Out" }

# Select only the relevant properties
$FilteredResult = $FilteredResult | Select-Object id, title, description, publicDisclosureAvailabilityDate, created, modified, status

# Reformat created and modified dates
$FilteredResult = $FilteredResult | ForEach-Object {
    $_.created = Get-Date $_.created -Format "MMMM d, yyyy"
    $_.modified = Get-Date $_.modified -Format "MMMM d, yyyy"
    $_
}

$FilteredResult = $FilteredResult | ForEach-Object {
    $_.created = Get-Date $_.created -Format "MMMM d, yyyy"
    $_.modified = Get-Date $_.modified -Format "MMMM d, yyyy"
    if ($_.publicDisclosureAvailabilityDate -match "^(.*) CY(\d{4})$") {
        $_.publicDisclosureAvailabilityDate = "$($Matches[1]) $($Matches[2])"
    }
    $_
}

# Sort by publicDisclosureAvailabilityDate (earliest first)
$SortedResult = $FilteredResult | Sort-Object {
    # Try to parse "Month Year" as a date (assume day 1)
    [datetime]::ParseExact($_.publicDisclosureAvailabilityDate, "MMMM yyyy", $null)
}

# Convert the filtered results to JSON and save to a file
$SortedResult | ConvertTo-Json -Depth 5 | Out-File -FilePath "CopilotFilteredResults.json" -Encoding utf8

Write-Output "JSON file 'CopilotFilteredResults.json' has been created."


# $FilteredResult | ConvertTo-Json
# $Result | ConvertTo-Json
# $Result | Select-Object id, title, description, publicDisclosureAvailabilityDate, created, modified, status -first 5 | ConvertTo-Json
# "Total items: $($Result.Count)"