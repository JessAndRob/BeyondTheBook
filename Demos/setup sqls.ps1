Set-DbatoolsInsecureConnection
$uri = 'https://taylor-swift-api.sarbo.workers.dev/songs'
$songs = Invoke-RestMethod -Uri $uri
$songs | ForEach-Object -ThrottleLimit 5 -Parallel {
    $song = $PSItem
    0..5 | ForEach-Object {
        $songname = "{0}-{1}" -f $_, $song.title
        $null = Invoke-DbaQuery -SqlInstance sql3 -Database master -Query "CREATE DATABASE [$songname] "
    }
    $null =  New-DbaAgentJob -SqlInstance sql3  -Job $song.title
}

$metallica = irm 'https://raw.githubusercontent.com/ricardoshiro/metallica/main/song-data/metallica_songs.csv' | ConvertFrom-Csv

$metallica.name | ForEach-Object -ThrottleLimit 5 -Parallel {
    $songname = $PSItem
    $null =  Invoke-DbaQuery -SqlInstance sql3 -Database master -Query "CREATE DATABASE [$songname] "
    $songname
    $null =   New-DbaAgentJob -SqlInstance sql3  -Job $songname
}
