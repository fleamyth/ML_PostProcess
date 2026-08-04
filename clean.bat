@echo off
for /f %%a in ('dir /s /b *.log') do del /s /q %%a
for /f %%a in ('dir /s /b *.dat') do del /s /q %%a
for /f %%a in ('dir /s /b *.txt') do del /s /q %%a
for /f %%a in ('dir /s /b *.csv') do del /s /q %%a
for /f %%a in ('dir /s /b Exception') do rmdir /s /q %%a
for /f %%a in ('dir /s /b SFISlogs') do rmdir /s /q %%a
for /f %%a in ('dir /s /b LANRSClientlogs') do rmdir /s /q %%a
for /f %%a in ('dir /s /b LANRSServerlogs') do rmdir /s /q %%a
for /f %%a in ('dir /s /b *.flg') do del /s /q %%a
for /f %%a in ('dir /s /b *.tmp') do del /s /q %%a
