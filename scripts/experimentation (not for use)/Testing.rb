# net = WSApplication.current_network
# puts net.class
require_relative '../../lib/models/network_utility'
require_relative '../../lib/models/sim_utility'

# sel = WSApplication.choose_selection("Prompt")
# puts sel.class
    # Open Database
db_file = "C:\\AI_ICM_DB\\AI_ICM_DB.icmm"
db = WSApplication.open(db_file,false)

# Navigate through database structure to retrieve desired model runs group 
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

# Open the first simulation instead of current_network
net = sims_array[0].open
# results_db = WSApplication.open(sims[0].results_path)
# puts "Read successfully"

begin
    table_name = "hw_node"
    sim_util = SimUtility.new(sims_array[0])
    # Get results dictionary for node_id and FloodDepth
    results_dict = sim_util.return_field_dictionary(table_name, "node_id", "FloodDepth")
    sim_util.export_dictionary_to_csv("output/testing.csv", results_dict, "node_id", "max_flood_depth (m)")
rescue => e
    puts "Error: #{e.message}"
end




sleep(100)
# begin
#     sim = sims_array[1]
#     net = sim.open
#     # node_results = net.row_objects("hw_2d_results_point")
#     # puts node_results.length
#     #puts net.table_names

#     results_array = Array.new
#     net.tables.each do |table|
#         puts "=> #{table.name.upcase}"
#         net.row_object_collection(table.name).each do |row_object|
#             if !row_object.table_info.results_fields.nil?
#                 row_object.table_info.results_fields.each do |field|
#                     results_array |= [field.name]
#                 end
#             end
#         end
#     end
#     puts results_array
#     puts ""
#     gets
# end

    # net.table_names.each do |table_name|
    #     if net.row_objects(table_name).length > 0
    #         puts "Name: #{table_name}, Size: #{net.row_objects(table_name).length}"
    #     end
    # end


    # results_table.each do |result|
    #     puts "Node: #{result.node_id}, Max Depth: #{result.depth_max}"
    # end

    # puts sim.class
    # puts sim.list_max_results_attributes
    #sim.max_results_csv_export(selection = nil, attributes = [["Node", ["flooddepth"]]], folder = "C:\\Git\\ICMScripts\\Output")
    #sim.max_results_csv_export(selection = nil, attributes = nil, folder = "C:\\Git\\ICMScripts\\Output")
    #net = sim.open # Converts sim from WSSimObject to WSOpenNetwork
    #puts net.class
    # Get 
    # Alternative: Print all object types to see what's available
    # db.root_model_objects.each do |obj|
    #     puts "Type: #{obj.type}, Path: #{obj.path}"
    #     obj.children.each do |child|
    #         puts "  Child Type: #{child.type}, Path: #{child.path}"
    #         child.children.each do |grandchild|
    #             puts "      Grandchild Type: #{grandchild.type}, Path: #{grandchild.path}, ID: #{grandchild.id}"
    #         end
    #     end
    # end
    
    # mo = db.model_object_from_type_and_id('Model Group', 10)
    # puts db.name


# rescue => e
#     puts "Error: #{e.message}"
#     sleep(100)
# end

# model_object = db.model_object_from_type_and_id('Model Network', 1)
# net = model_object.open

# net.current_scenario = 'POC_Area_v1'
# db.root_model_objects.each do |o|
#     o.children.each do |c|
#         puts c.path
#     end
# end

# results_table = net.row_objects("hw_1d_results_point")

# puts results_table[0].class


# mh = net.row_object("hw_node", "MH417663")

# puts mh.DEPNOD
# user_input = gets.chomp
# # Print out upstream links from manhole
# if mh.us_links.length == 0
#   puts "No upstream links for manhole: #{mh.id}"
# else
#     puts "Upstream links for manhole: #{mh.id}"
#     mh.us_links.each do |link|
#       puts link.id
#     end
#   end

# puts "finished"