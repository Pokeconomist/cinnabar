# allow powershell scripts to be run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

cd .\src\
ruby .\cinnabar.rb