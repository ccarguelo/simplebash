#! /bin/bash
export LANG=en_US.UTF-8
export LOCALE=UTF-8
unset tecreset loadaverage
EMAILS="abaltodano@apploaded.com,alvin@apploaded.com,carguello@apploaded.com,hayseli@apploaded.com"


	if [[ $# -eq 0 ]]
	then
{
## ---------------------------- Check System Uptime --------------------

	if
		tecuptime=$(uptime -p)
	then {
		echo " ------------------------------------------------------------"
		echo "" 
		echo "	  System Uptime :" $tecreset $tecuptime
		echo ""
	}
fi

## ---------------------------------------------------------------------


## ------------------------------- Define Variable tecreset ------------

		tecreset=$(tput sgr0)

## ------------------------------ Check RAM and SWAP Usage -------------
		
		echo ""
		echo " ----------------- Check RAM and SWAP Usage -----------------"
		echo ""
		free -mh
	
		echo ""
		echo " ------------------------------------------------------------"
		echo ""
	
## ------------------------------- Check Disk Usage --------------------

	if
		df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
	then
		{
		echo "Disk Usage :" $tecreset
		echo ""
		cat /tmp/diskusage
		echo ""
		echo " ------------------------------------------------------------"	
	}
fi

## ----------------------------- Check Load Average --------------------

	if
		echo ""
		cpu_cores=`cat /proc/cpuinfo | grep 'processor' | wc -l`
		loadaverage=$(uptime | grep 'load average' | awk '{print $12}')
	then {
		echo "Load Average :" $tecreset $loadaverage
		echo ""
		echo " ------------------------------------------------------------"
	}
fi
		
	if [[ "$cpu_cores" > "$loadaverage" ]]
		echo ""
	then {
		echo "CPU Load is at Normal levels - Below the number of cores."
		echo "Load is at $loadaverage - Number of cores is $cpu_cores."
	}
fi

	if [[ "$cpu_cores" <  "$loadaverage" ]]
	then {
		echo "CPU Load is above number of cores."
		echo "Load is at = $loadaverage - Number of cores is : $cpu_cores."
		
		echo "WARNING CPU Load is at maximum capacity. Please check the Server Operations." | 
		mail -s "Warning Log" -a /tmp/Logs/*.txt carguello@apploaded.com
}
fi

	if [[ "$cpu_cores" = "$loadaverage" ]]
	then {
		echo "CPU Load is at maximum capacity. Please check the Server Operations"
		echo "Load is at = $loadaverage - Number of cores is $cpu_cores."
		
		echo "WARNING CPU Load is at maximum capacity. Please check the Server Operations." | 
		mail -s "Warning Log" -a /tmp/Logs/*.txt carguello@apploaded.com
}
fi

## ----------------------------- Unset Variables -----------------------

		unset tecreset  loadaverage

}
fi
shift $(($OPTIND -1))
