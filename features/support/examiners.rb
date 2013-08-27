AfterStep('@slow_motion') do
  sleep 2
end

AfterStep('@single_step') do
  print "Single Stepping. Hit enter to continue"
  STDIN.getc
end