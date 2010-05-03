require 'rails_env'
p $test
$test = true
puts Organization.count