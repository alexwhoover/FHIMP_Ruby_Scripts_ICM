require_relative '../../lib/models/network_utility'

# IExchange code
mh_id = 'MH417670'
db = WSApplication.open
model_object = db.model_object_from_type_and_id('Model Network', 1)
net = model_object.open
net.current_scenario = 'POC_Area_v1'
puts "Current scenario: #{net.current_scenario}"

# If running in UI, use following code instead to get the current network:
# net = WSApplication.current_network
# net_utility = NetworkUtility.new(net)


net_utility = NetworkUtility.new(net)

# Ruby in ICM doesn't have a built-in CSV library, so we will manually create a CSV format

rows = []
header = [
    "manhole_id",
    "upstream_pipe_count",
    "upstream_pipe_total_length",
    "upstream_pipe_weighted_avg_diameter",
    "upstream_pipe_weighted_avg_gradient",
    "upstream_storm_impervious_area",
    "upstream_sanitary_population",
	"stream_order"
]
rows << header

net_utility.nodes.each do |mh|
	# Calculate upstream statistics for each manhole, then append to rows
	upstream = net_utility.return_upstream(mh)

    pipe_count = net_utility.count_upstream_pipes(upstream)
    total_length = net_utility.calculate_total_length_upstream_pipes(upstream)
    avg_diameter = net_utility.calculate_weighted_average_diameter(upstream)
    avg_gradient = net_utility.calculate_weighted_average_gradient(upstream)
    storm_impervious = net_utility.calculate_upstream_impervious_area_storm(upstream)
    sanitary_population = net_utility.calculate_upstream_population_sanitary(upstream)
	stream_order = net_utility.calculate_shreve_stream_order(upstream)

    row = [
        mh.id,
        pipe_count,
        total_length,
        avg_diameter,
        avg_gradient,
        storm_impervious,
        sanitary_population,
        stream_order
    ]
    rows << row

	puts "Processed manhole: #{mh.id}"
end

File.open("C:/Git/ICMScripts/summary_statistics_v2.csv", "w") do |file|
    rows.each { |row| file.puts row.join(",") }
end

puts "Finished calculations"


