function get-blocksize 
{   
      [CmdletBinding()] 
      Param
      (
      [Parameter(Mandatory=$True)] 
      [string]$volume,
      [int]$sampleinterval,
      [int]$maxsamples 
      )        
        $outfile = 'c:\scripts\blocksize.csv' 
        $array = @()
        $perfomancesampledata = Get-Counter -Counter "\LogicalDisk(*)\Disk Bytes/sec", "\LogicalDisk(*)\Disk Transfers/sec" -SampleInterval $sampleinterval -MaxSamples $maxsamples        
        foreach ($p in $perfomancesampledata )
            {        
                $throughput = ($p.CounterSamples |  ? instancename -match "$volume" | ? path -Match "bytes")  
                $iops = ($p.CounterSamples |  ? instancename -match "$volume" | ? path -Match "transfers")        
                $PerfomanceData = New-Object psobject
                $PerfomanceData | Add-Member -type NoteProperty -name 'timestamp' -Value $p.TimeStamp
                $PerfomanceData | Add-Member -type NoteProperty -name 'iops' -Value ("{0:n1}" -f ($iops.CookedValue))
                $PerfomanceData | Add-Member -type NoteProperty -name 'throughput(KBps)' -Value ("{0:n1}" -f ($throughput.CookedValue / 1kb))
                $PerfomanceData | Add-Member -type NoteProperty -name 'throughput(MBps)' -Value ("{0:n1}" -f ($throughput.CookedValue / 1mb))
                $PerfomanceData | Add-Member -type NoteProperty -name 'blocksize(kb)' -Value ("{0:n1}" -f (($throughput.CookedValue / 1kb) / ($iops.CookedValue)))
                $array+=$PerfomanceData                                       
            }                    
                $array | Export-Csv -Path $outfile -Delimiter "," -NoTypeInformation -Encoding UTF8 
}
