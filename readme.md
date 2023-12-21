# Automation for payemtns process. 

This project pulls data from the database connected to ClubFeast admin, then generates a .csv file
with the needed fields for driver payment reports. Currently only handles Bay Area and EC.

* query.sql contains the needed query
* main.py is the actual script that pulls the data 

## Output 

A csv file containing the post shift report per coast (2 files).