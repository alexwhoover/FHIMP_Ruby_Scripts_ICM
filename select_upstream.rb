class NetworkUtility
	attr_accessor :network, :catchments, :links, :nodes

	# Constructor
	def initialize(network)
		@network = network
		@catchments = @network.row_objects('_subcatchments')
		@links = @network.row_objects('_links')
		@nodes = @network.row_objects('_nodes')
	end

	def select_all_nodes()
		@network.clear_selection
		@nodes.each do |node|
			node.selected = true
		end
	end

	def select_upstream(mh)
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

	def select_upstream_nodes(mh)
		# Method to select all upstream nodes from a given manhole ID
		# Returns void
		nodes = select_upstream(mh)[:nodes]

		nodes.each do |node|
			node.selected = true
		end
	end

	def select_upstream_links(mh)
		# Method to select all upstream links from a given manhole ID
		# Returns void
		links = select_upstream(mh)[:links]

		links.each do |link|
			link.selected = true
		end
	end

	def select_upstream_catchments(mh)
		# Method to select all upstream catchments from a given manhole ID
		# Returns void
		catchments = select_upstream(mh)[:catchments]

		catchments.each do |catchment|
			catchment.selected = true
		end
	end

	def select_upstream_all(mh)
		# Method to select all upstream nodes, links, and catchments from a given manhole ID
		# Returns void

		select_upstream_nodes(mh)
		select_upstream_links(mh)
		select_upstream_catchments(mh)
	end

	def count_upstream_pipes(mh)
		# Method to count all upstream pipes from a given manhole ID
		# Returns the count of upstream pipes

		upstream_links = select_upstream(mh)[:links]
		return upstream_links.size
	end

	def calculate_total_length_upstream_pipes(mh)
		# Method to calculate the total length of all upstream pipes from a given manhole ID
		# Returns the total length of upstream pipes

		upstream_links = select_upstream(mh)[:links]
		total_length = 0.0

		upstream_links.each do |link|
			total_length += link.conduit_length
		end

		return total_length
	end

	def calculate_weighted_average_diameter(mh)
		# Method to calculate the length weighted average diameter of all upstream pipes from a given manhole ID
		# Returns the length weighted average diameter

		upstream_links = select_upstream(mh)[:links]
		total_diameter = 0.0
		total_length = 0.0

		upstream_links.each do |link|
			total_diameter += link.conduit_width * link.conduit_length
			total_length += link.conduit_length
		end

		return total_length > 0 ? (total_diameter / total_length) : 0.0
	end

	def calculate_weighted_average_gradient(mh)
		# Method to calculate the length weighted average slope of all upstream pipes from a given manhole ID
		# Returns the length weighted average slope

		upstream_links = select_upstream(mh)[:links]
		total_slope = 0.0
		total_length = 0.0

		upstream_links.each do |link|
			total_slope += link.gradient * link.conduit_length
			total_length += link.conduit_length
		end

		return total_length > 0 ? (total_slope / total_length) : 0.0
	end



end

mh_id = 'MH409133'
net = WSApplication.current_network
net_utility = NetworkUtility.new(net)
mh = net.row_object('hw_node', mh_id)
net_utility.select_upstream_links(mh)
puts net_utility.count_upstream_pipes(mh)
puts net_utility.calculate_total_length_upstream_pipes(mh)
puts net_utility.calculate_weighted_average_diameter(mh)






