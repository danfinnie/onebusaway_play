cf push gtfs-0 &
PID_0=$!
sleep 1
cf push gtfs-1 &
PID_1=$!
sleep 1
cf push gtfs-2 &
PID_2=$!
sleep 1
cf push gtfs-3 &
PID_3=$!
sleep 1
cf push gtfs-4 &
PID_4=$!
sleep 1
cf push gtfs-5 &
PID_5=$!
sleep 1
cf push gtfs-6 &
PID_6=$!
sleep 1
cf push gtfs-7 &
PID_7=$!
sleep 1
cf push gtfs-8 &
PID_8=$!
sleep 1
cf push gtfs-9 &
PID_9=$!
sleep 1
cf push gtfs-10 &
PID_10=$!

wait $PID_0 $PID_1 $PID_2 $PID_3 $PID_4 $PID_5 $PID_6 $PID_7 $PID_8 $PID_9 $PID_10
