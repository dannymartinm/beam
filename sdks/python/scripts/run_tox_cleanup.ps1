 #Checking that we have the correct path in the PWD
 if (Test-Path $PWD/sdks/python) {
    Write-Output "Unable to locate Apache Beam Python SDK root directory"
    exit 1
}

Get-ChildItem apache_beam -recurse -include *.pyc | remove-item

Get-ChildItem apache_beam -recurse -include *.c | remove-item

Get-ChildItem apache_beam -recurse -include *.so | remove-item

Get-ChildItem target/build -recurse -include *.pyc | remove-item

Get-ChildItem target/build -recurse -include *.c | remove-item

Get-ChildItem target/build -recurse -include *.so | remove-item