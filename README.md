# Introduction 
This repository uses InfoWorks ICM's built-in Ruby scripting capabilities to calculate and format network statistics, design storm data, and simulation results into a dataset for use in the AI/ML Flood Hazard Mapping Project.

# The Ruby Interface for InfoWorks ICM
This section describes how to use the Ruby interface for InfoWorks ICM, summarized from the lengthy documentation PDF here: https://help.autodesk.com/lessons/IWICMS_2024_ENU/files/Exchange.pdf. It is assumed that the reader is familiar with fundamental object-oriented programming concepts and terminology.
## Running a Script
A ruby script may be run in two ways:
1. Inside the user interface of ICM, or
2. In the terminal using the format \*PATH TO IExchange.exe (found in ICM install folder)\* \*PATH TO SCRIPT.rb\* \*ICM/IA/WS (Use ICM)\* \*EXTRA ARGUMENTS (Optional)\*. For example, based on my path locations, I could run:

```
"C:\Program Files\Autodesk\InfoWorks ICM Ultimate 2026\ICMExchange.exe" "C:\Git\ICMScripts\Testing.rb" ICM
```
## The Exchange Object Model
**WSApplication** <br>
Represents the top-level of the application. With this class, one can get and set global settings, create / open databases (of WSDatabase class), and run simulations.

- *open(path, bUpdate) or open(path, version) or open(path) or open* <br>
-- opens the database with path *path*
-- returns an object of type WSDatabase
- *current_network* (UI Only) <br>
- *launch_sims(sims, server, results_on_server, max_threads, after)* <br>
-- sims: An array of WSModelObject objects for the simulations <br>
-- server: '.' for the local machine <br>
-- results_on_server: Boolean <br>
-- max_threads: 0 to allow sim agent to choose <br>
-- after: 0 for run now <br>
-- returns an array of job ID strings <br>
- *wait_for_jobs(array_of_job_ids, wait_for_all, timeout)* <br>
-- array_of_job_ids: From *launch_sims* <br>
-- wait_for_all: True to wait for all, false to wait for one <br>
-- timeout: Timeout time in ms <br>
- *results_folder* <br>
-- returns the current results folder as a string <br>
- *set_working_folder(path)* <br>
- *set_results_folder(path)* <br>
- *ui?* <br>
-- returns true or false if run in UI or IExchange <br>

**WS Database** <br>
Represents master and transportable databases.

- *find_model_object(type, name)* <br>
-- type: Example is 'Model Network' <br>
-- only works for version controlled objects, as these objects have unique names <br>
- *model_object(scripting_path)* <br>
-- returns the model object with that path. <br>
-- example is mo = db.model_object('>MODG~My Root Model Group') <br>
- *model_object_collection(type)* <br>
-- returns a WSModelObjectCollection of all the objects of that type <br>
- *path* <br>
-- returns the pathname of the master database as a string <br>
- *root_model_objects* <br>
-- returns a WSModelObjectCollection of all the objects in the root of that database <br>
- *result_root* <br>
-- returns the root used for results files for the database <br>

**WSModelObject** <br>
Represents individual tree objects such as stored queries, ICM runs, etc.

- Use ['field_name'] to grab or set values. This is most useful for the InfoWorks Run object.
- *children* returns the children of the object as a WSModelObjectCollection
- *name*
- *new_run(name, network, commit_id, rainfalls_and_flow_surveys, scenarios, parameters)
- *open*  <br>
-- returns a WSOpenNetwork corresponding to the model object, provided that the model object is of type network or sim <br>
-- when called on a sim, the network will be opened with the results of the simulation loaded into it. <br>
- *path*
- *type*

**WSOpenNetwork** <br>
Represents networks.

- *current_scenario* <br>
-- Set current scenario <br>
-- each or each_selected do |x| to iterate through <br>
- *model_object* <br>
-- returns a WSModelObject associated with the WSOpenNetwork. If a sim was opened to obtain the WSOpenNetwork, the model object of that sim will be returned <br>
- *row_object(table, id)*
- *row_objects(table)*

**WSRowObjectCollection**, **WSRowObject**, **WSNode**, and **WSLink** <br>
These classes represent the objects in the network. The object returned from WSRowObjectCollection will be WSNode for a node, WSLink for a link, or WSRowObject otherwise.

*WSNode* extends the *WSRowObjectClass*
- *us_links*, *ds_links*

*WSLink* extends the *WSRowObjectClass*
- *us_node*, *ds_node*

*WSRowObjectCollection*
- Use [i] to access i'th object in collection
- *length* for number of objects in collection
- Use roc.each do |ro| to iterate

*WSRowObject*
- IMPORTANT: Use *results* to access the results fields of a given row object. This is how you can get the simulation results such as flood depth, etc.

**WSModelObjectCollection**
- Use [i] to access i'th object in collection
- *count* returns number of objects in collection
- Use *moc.each do |mo|* to iterate through collection

**WSSimObject**
- *max_results_csv_export(selection, attributes, folder)* <br>
-- exports the results for the simulation in the CSV format corresponding to that used in the CSV results export menu option <br>
-- selection: can be ID, scripting path, WSModelObject, or nil <br>
- *run* <br>
-- Runs a simulation, waiting until the simulation finishes.  <br>
- *status*
- *success_substatus*

