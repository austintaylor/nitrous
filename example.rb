require 'rails_env'
p $test
$test = true
sleep 5
puts Organization.count