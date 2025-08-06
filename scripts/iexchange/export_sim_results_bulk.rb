require_relative '../../lib/models/network_utility'
require_relative '../../lib/models/sim_utility'

# IExchange code
db = WSApplication.open

# Navigate through database structure to retrieve desired model runs group 
runs = db.model_object('>MASG~Cambie-Heather (CAH)>MASG~CAH-Existing>MODG~Model Runs>MODG~System Performance Runs')
puts runs.class
sims_array = Array.new
runs.children.each do |run|
    if run.type == 'Run'
        run.children.each do |sim| 
            puts "Found a sim called #{sim.name} within run #{run.name}"
            puts "Results path is #{sim.results_path}"
            puts "Sim status is #{sim.status}, #{sim.success_substatus}"
            puts sim.name
            sims_array << sim
        end
    end
end

begin
    sims_array.each do |sim|
        sim_util = SimUtility.new(sim)
        sim_util.export_dictionary_to_csv("output/sim_results/sim_#{sim.name}_results.csv", "hw_node", "node_id", "FloodDepth")
    end
rescue => e
    puts "Error exporting run results: #{e.message}"
end


