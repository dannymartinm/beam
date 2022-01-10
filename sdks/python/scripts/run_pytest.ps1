$envname = $args[0]
$posargs = $args[1]
$pytest_args = $args[2]

Write-Output $envname
Write-Output $posargs
Write-Output $pytest_args

if ( ($pytest_args -match "-m") -or ($posargs -match "-m") ) {
  Write-Output "posargs and pytest args cannot be called with -m as it interferes with 'no_xdist' logic, see BEAM-12985."  
  exit 1
}
#Run with pytest -xdist and without
pytest -o junit_suite_name=$envname --junitxml=pytest_$envname.xml -m 'not no_xdist' -n 4 $pytest_args --pyargs $posargs
$status1 = $LASTEXITCODE
pytest -o junit_suite_name=$envname_no_xdist --junitxml=pytest_$envname_no_xdist.xml -m 'no_xdist' $pytest_arg --pyargs $posargs
$status2 = $LASTEXITCODE


Write-Output "Status Results--------------------------"
Write-Output $status1
Write-Output $status2

if ( ($status1 -eq 5) -and ($status2 -eq 5)) {
  exit $status1 
}

if ($status1 -and ($status1 -ne 5)) {
  exit $status1
}

if ($status2 -and ($status2 -ne 5)) {
  exit $status2
}