@echo off
if defined MAVEN_HOME (call "%MAVEN_HOME%\bin\mvn.cmd" %*) else (mvn %*)
