while true; do 
	curl http://127.0.0.1:80/v1/poller/poke -m 1 1>/dev/null 2>&1
	sleep 2
done
