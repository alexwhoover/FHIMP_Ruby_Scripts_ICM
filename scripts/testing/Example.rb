db_file = "C:\\AI_ICM_DB\\AI_ICM_DB.icmm"
db = WSApplication.open(db_file,false)

runs = db.model_object('>MASG~Cambie-Heather (CAH)>MASG~CAH-Existing>MODG~Model Runs>MODG~System Performance Runs')

# Add all the sims within the run group to an array sims_array
sims_array = Array.new
runs.children.each do |run|
    if run.type == 'Run'
        run.children.each do |sim| 
            puts "Found a sim called #{sim.name} within run #{run.name}"
            puts "Results path is #{sim.results_path}"
            puts "Sim status is #{sim.status}, #{sim.success_substatus}"
            sims_array << sim
        end
    end
end

puts sims_array[0].class # WSSimObject
sleep(100000)