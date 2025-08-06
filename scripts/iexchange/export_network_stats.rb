require_relative '../../lib/models/network_utility'
require_relative '../../lib/models/sim_utility'

# IExchange code
db = WSApplication.open
model_object = db.model_object_from_type_and_id('Model Network', 1)
net = model_object.open
net.current_scenario = 'POC_Area_v1'
puts "Current scenario: #{net.current_scenario}"

# If running in UI, use following code instead to get the current network:
# net = WSApplication.current_network

net_utility = NetworkUtility.new(net)

begin
    net_utility.export_summary_stats_csv("C:/Git/ICMScripts/summary_statistics_v3.csv")
rescue => e
    puts "Error exporting summary stats: #{e.message}"
end

puts "Finished calculations"


