<#
    .SYNOPSIS
    Script get information from windows storarage sybsystem perfomance counters:

    timestamp 
    iops
    latency(ms)
    throughput(KBps)
    throughput(MBps)
    blocksize

    Version 1.0, 2020-01-18

    .LINK  
    https://github.com/budreev/blocksize
    	
    .PARAMETER Volume
    Specify disk letter     

    .PARAMETER Sampleinterval
    Specifies the number of samples to get from each specified performance counter. Minimum - 1 
    
    .PARAMETER Maxsamples
    Specifies the number of samples to get from each specified performance counter 


    .EXAMPLE
    . .\get-blocksize.ps1 -volume "c" -sampleinterval 1 -maxsamples 20

    .OUTPUT
    Outfile you can find in CSV format c:\scripts\blocksize.csv
      
    timestamp	    iops	    latency	throughput(KBps)	throughput(MBps)	blocksize(kb)
    1/18/2020 20:40	18,573.50	1.69	74,292.20	        72.6	            4
    1/18/2020 20:40	19,830.90	1.54	79,334.20	        77.5	            4
    1/18/2020 20:40	16,798.70	1.6	    67,254.50	        65.7	            4
    1/18/2020 20:40	20,447.40	1.37	81,805.40	        79.9	            4
    1/18/2020 20:40	17,279.80	1.66	69,223.00	        67.6	            4
    1/18/2020 20:40	20,183.00	1.39	80,792.00	        78.9	            4
    1/18/2020 20:40	13,939.50	2.06	55,874.10	        54.6	            4
    1/18/2020 20:40	13,090.60	2.52	52,362.30	        51.1	            4
    1/18/2020 20:40	19,931.10	1.59	79,736.30	        77.9	            4
#>
function get-blocksize 
{   
      [CmdletBinding()] 
      Param
      (
      [Parameter(Mandatory=$True)] 
      [string]$volume, # volume name
      [int]$sampleinterval, 
      [int]$maxsamples 
      )        
        $outfile = 'c:\scripts\blocksize.csv' 
        $array = @()
        $perfomancesampledata = Get-Counter -Counter "\LogicalDisk(*)\Disk Bytes/sec", "\LogicalDisk(*)\Disk Transfers/sec", "\LogicalDisk(*)\Avg. Disk sec/Transfer" -SampleInterval $sampleinterval -MaxSamples $maxsamples        
        foreach ($p in $perfomancesampledata )
            {        
                $throughput = ($p.CounterSamples |  ? instancename -match "$volume" | ? path -Match "bytes")  
                $iops = ($p.CounterSamples |  ? instancename -match "$volume" | ? path -Match "transfers")
                $latency = ($p.CounterSamples | ? instancename -match "$volume" | ? path -Match "avg. disk sec")      
                $PerfomanceData = New-Object psobject
                $PerfomanceData | Add-Member -type NoteProperty -name 'timestamp' -Value $p.TimeStamp
                $PerfomanceData | Add-Member -type NoteProperty -name 'iops' -Value ("{0:n1}" -f ($iops.CookedValue))
                $PerfomanceData | Add-Member -type NoteProperty -name 'latency(ms)' -Value ("{0:n2}" -f (($latency.CookedValue) * 1000))
                $PerfomanceData | Add-Member -type NoteProperty -name 'throughput(KBps)' -Value ("{0:n1}" -f ($throughput.CookedValue / 1kb))
                $PerfomanceData | Add-Member -type NoteProperty -name 'throughput(MBps)' -Value ("{0:n1}" -f ($throughput.CookedValue / 1mb))
                $PerfomanceData | Add-Member -type NoteProperty -name 'blocksize(kb)' -Value ("{0:n1}" -f (($throughput.CookedValue / 1kb) / ($iops.CookedValue)))
                $array+=$PerfomanceData                                       
            }                    
                $array | Export-Csv -Path $outfile -Delimiter "," -NoTypeInformation -Encoding UTF8 
}

