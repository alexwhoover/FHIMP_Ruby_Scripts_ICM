# NetworkUtility
#
# This class provides analytical and utility methods for working with a proprietary WSOpenNetwork object,
# which represents a network of nodes (e.g., manholes), links (e.g., pipes), and catchments (e.g., drainage areas).
# The WSOpenNetwork class cannot be modified directly, so NetworkUtility acts as a wrapper to extend its functionality.
#
# Key Features:
# - Traverses the network upstream from a given node (manhole), selecting all upstream nodes, links, and catchments.
# - Calculates various network statistics, including:
#   - Shreve stream order (number of headwater nodes upstream)
#   - Total count and length of upstream pipes
#   - Length-weighted average diameter and gradient of upstream pipes
#   - Total impervious area for stormwater catchments upstream
#   - Total population for sanitary catchments upstream
# - Exports summary statistics for all manholes to a CSV file.
#
# Usage:
#   utility = NetworkUtility.new(network)
#   upstream = utility.return_upstream(manhole_node)
#   stream_order = utility.calculate_shreve_stream_order(upstream)
#   pipe_count = utility.count_upstream_pipes(upstream)
#   total_length = utility.calculate_total_length_upstream_pipes(upstream)
#   avg_diameter = utility.calculate_weighted_average_diameter(upstream)
#   avg_gradient = utility.calculate_weighted_average_gradient(upstream)
#   impervious_area = utility.calculate_upstream_impervious_area_storm(upstream)
#   population = utility.calculate_upstream_population_sanitary(upstream)
#   utility.export_summary_stats_csv("output.csv") # Exports statistics for all manholes
#
# Note:
# - The class uses a breadth-first search algorithm to traverse the network upstream.
# - The @_seen attribute is used internally to track visited nodes and links during traversal.
# - All analytical methods operate on the upstream selection returned by `return_upstream`.
# - The `export_summary_stats_csv` method generates a CSV file containing summary statistics for each manhole in the network.


class NetworkUtility
	# Getters and setters
	attr_accessor :network, :catchments, :links, :nodes

	# Constructor
	def initialize(network)
		@network = network
		@catchments = @network.row_objects('_subcatchments')
		@links = @network.row_objects('_links')
		@nodes = @network.row_objects('_nodes')
	end

	def return_upstream(mh)
		# Method to select all upstream nodes, links, and catchments from a given manhole object
		# Returns a hash with selected nodes, links, and catchments

		# Arrays to hold catchments, links, and nodes
		selected_nodes = []
		selected_links = []
		selected_catchments = []
		
		# Find the starting manhole node from @nodes
		#mh = @nodes.find { |node| node.id == manhole_id }
		return {nodes: [], links: [], catchments: []} unless mh  # Exit if not found

		# Using ._seen attribute to track visited nodes and links

		mh._seen = true
		selected_nodes << mh

		# Select catchments draining to the starting node
		@catchments.each do |catchment|
			selected_catchments << catchment if catchment.node_id == mh.id
		end

		# Create empty array to hold unprocessed links
		unprocessed_links = []

		# Add all upstream links from the starting node to the array
		mh.us_links.each do |link|
			unless link._seen
				unprocessed_links << link
				link._seen = true
			end
		end

		# Process each link in the array. The array acts as a queue and adds links to the end as they are found upstream.
		# This is a breadth-first search approach. (https://www.geeksforgeeks.org/dsa/breadth-first-search-or-bfs-for-a-graph/)
		while unprocessed_links.size > 0
			working_link = unprocessed_links.shift
			selected_links << working_link
			working_us_node = working_link.us_node

			# If the upstream node exists and hasn't been visited
			if working_us_node && !working_us_node._seen
				selected_nodes << working_us_node

				# Select catchments draining to this upstream node
				@catchments.each do |catchment|
					selected_catchments << catchment if catchment.node_id == working_us_node.id
				end

				# Add all upstream links from this node to the queue
				working_us_node.us_links.each do |link|
					unless link._seen
						unprocessed_links << link
						link._seen = true              # Mark link as visited
					end
				end

				working_us_node._seen = true      # Mark node as visited
			end
		end

		# Clear the @_seen attribute from all nodes and links to reset for future selections
		(@nodes + @links).each do |obj|
			obj._seen = false
		end

		# Return the selected nodes, links, and catchments
		return {nodes: selected_nodes, links: selected_links, catchments: selected_catchments}
	end

	def calculate_shreve_stream_order(upstream)
		# Method to calculate the Shreve stream order for a given upstream selection
		# Count headwater nodes (nodes with no upstream links)
		headwater_count = upstream[:nodes].count { |node| node.us_links.length == 0 }
		
		# For Shreve method, the stream order at this point equals the number of headwater nodes
		return headwater_count
	end		


	def count_upstream_pipes(upstream)
		# Method to count all upstream pipes from a given manhole ID
		# Returns the count of upstream pipes
		return upstream[:links].size
	end

	def calculate_total_length_upstream_pipes(upstream)
		# Method to calculate the total length of all upstream pipes from a given manhole ID
		# Returns the total length of upstream pipes

		total_length = 0.0

		upstream[:links].each do |link|
			total_length += link.conduit_length
		end

		return total_length
	end

	def calculate_weighted_average_diameter(upstream)
		# Method to calculate the length weighted average diameter of all upstream pipes from a given manhole ID
		# Returns the length weighted average diameter

		total_diameter = 0.0
		total_length = 0.0

		upstream[:links].each do |link|
			total_diameter += link.conduit_width * link.conduit_length
			total_length += link.conduit_length
		end

		return total_length > 0 ? (total_diameter / total_length) : 0.0
	end

	def calculate_weighted_average_gradient(upstream)
		# Method to calculate the length weighted average slope of all upstream pipes from a given manhole ID
		# Returns the length weighted average slope
		total_slope = 0.0
		total_length = 0.0

		upstream[:links].each do |link|
			total_slope += link.gradient * link.conduit_length
			total_length += link.conduit_length
		end

		return total_length > 0 ? (total_slope / total_length) : 0.0
	end

	def calculate_upstream_impervious_area_storm(upstream)
		# Method to calculate the total upstream impervious area for stormwater catchments upstream from a given manhole ID
		# Returns the total impervious area
		total_impervious_area = 0.0
		total_pervious_area = 0.0
		total_area = 0.0

		upstream[:catchments].each do |catchment|
			if catchment.system_type == 'storm'
				# COV defines catchment areas 1, 2, 3, 4 as impervious
				imperv_percent = catchment.area_percent_1 + catchment.area_percent_2 + catchment.area_percent_3 + catchment.area_percent_4
				perv_percent = catchment.area_percent_5 + catchment.area_percent_6 + catchment.area_percent_7
				total_impervious_area += catchment.total_area * (imperv_percent / 100.0)
				total_pervious_area += catchment.total_area * (perv_percent / 100.0)
				total_area += catchment.total_area
			end
		end

		return {total_impervious_area: total_impervious_area, total_pervious_area: total_pervious_area, total_area: total_area}
	end

	def calculate_upstream_population_sanitary(upstream)
		# Method to calculate the total upstream population for sanitary catchments upstream from a given manhole ID
		# Returns the total population

		total_population = 0.0

		upstream[:catchments].each do |catchment|
			if catchment.system_type == 'sanitary'
				total_population += catchment.population
			end
		end

		return total_population
	end

	def calculate_depth_to_invert(mh)
		# Method to calculate the depth to invert at manhole
		depth = mh.flood_level - mh.chamber_floor
		return depth
	end

	def export_summary_stats_csv(output_path)
		# Method to generate summary statistics for all manholes and export to CSV
        # Returns the number of manholes processed
		rows = []
        header = [
            "manhole_id",
			"depth_to_invert",
            "upstream_pipe_count",
            "upstream_pipe_total_length",
            "upstream_pipe_weighted_avg_diameter",
            "upstream_pipe_weighted_avg_gradient",
            "upstream_storm_impervious_area",
			"upstream_storm_pervious_area",
			"upstream_storm_total_area",
            "upstream_sanitary_population",
            "stream_order"
        ]
        rows << header

		@nodes.each do |mh|
            # Calculate upstream statistics for each manhole
            upstream = return_upstream(mh)

			# Calculate network stats for export
			depth_to_invert = calculate_depth_to_invert(mh)
            pipe_count = count_upstream_pipes(upstream)
            total_length = calculate_total_length_upstream_pipes(upstream)
            avg_diameter = calculate_weighted_average_diameter(upstream)
            avg_gradient = calculate_weighted_average_gradient(upstream)
            storm_areas = calculate_upstream_impervious_area_storm(upstream) # Returns hashmap
            sanitary_population = calculate_upstream_population_sanitary(upstream)
            stream_order = calculate_shreve_stream_order(upstream)

			# Add manhole stats to a row in CSV
            row = [
                mh.id,
				depth_to_invert,
                pipe_count,
                total_length,
                avg_diameter,
                avg_gradient,
                storm_areas[:total_impervious_area],
				storm_areas[:total_pervious_area],
				storm_areas[:total_area],
                sanitary_population,
                stream_order
            ]
            rows << row

            puts "Processed manhole: #{mh.id}"
        end

        # Write to CSV file
        File.open(output_path, "w") do |file|
            rows.each { |row| file.puts row.join(",") }
        end

        puts "Summary statistics exported to: #{output_path}"
        return @nodes.size
    end
end