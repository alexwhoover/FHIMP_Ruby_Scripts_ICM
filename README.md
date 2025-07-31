# Introduction 
This repository uses InfoWorks ICM's built-in Ruby scripting capabilities to calculate and format network statistics, design storm data, and simulation results into a dataset for use in the AI/ML Flood Hazard Mapping Project.

# The Ruby Interface for InfoWorks ICM
This section describes how to use the Ruby interface for InfoWorks ICM, summarized from the lengthy documentation PDF here: https://help.autodesk.com/lessons/IWICMS_2024_ENU/files/Exchange.pdf.
## Running a Script
A ruby script may be run in two ways:
1. Inside the user interface of ICM, or
2. In the terminal using the format \*PATH TO IExchange.exe (found in ICM install folder)\* \*PATH TO SCRIPT.rb\* \*ICM/IA/WS (Use ICM)\* \*EXTRA ARGUMENTS (Optional)\*. For example, based on my path locations, I could run:

```
"C:\Program Files\Autodesk\InfoWorks ICM Ultimate 2026\ICMExchange.exe" "C:\Git\ICMScripts\Testing.rb" ICM
```