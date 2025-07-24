# Selects all upstream links and nodes from a given manhole ID in the current network.
# def select_upstream(manhole_id)
#   net = WSApplication.current_network
#   net.clear_selection  # Deselect everything to start fresh

#   catchments = net.row_objects('_subcatchments')

#   mh = net.row_object('hw_node', manhole_id)  # Find the starting manhole node
#   return unless mh  # Exit if not found

#   mh.selected = true  # Select the starting node
#   mh._seen = true     # Mark as visited to avoid loops

#   # Select catchments draining to the starting node
#   catchments.each do |catchment|
#     c.selected = true if catchment.node_id == mh.id
#   end

#   unprocessedLinks = []  # Queue for links to process

#   # Add all upstream links from the starting node to the queue
#   mh.us_links.each do |l|
#     unless l._seen
#       unprocessedLinks << l
#       l._seen = true  # Mark link as visited
#     end
#   end

#   # Process each link in the queue
#   while unprocessedLinks.size > 0
#     working = unprocessedLinks.shift  # Get next link
#     working.selected = true           # Select the link
#     workingUSNode = working.us_node   # Get the upstream node of this link

#     # If the upstream node exists and hasn't been visited
#     if !workingUSNode.nil? && !workingUSNode._seen
#       workingUSNode.selected = true   # Select the upstream node

#       # Select catchments draining to this upstream node
#       catchments.each do |catchment|
#         catchment.selected = true if catchment.node_id == workingUSNode.id
#       end
#       # Add all upstream links from this node to the queue
#       workingUSNode.us_links.each do |l|
#         unless l._seen
#           unprocessedLinks << l
#           l.selected = true           # Select the link immediately
#           l._seen = true              # Mark link as visited
#         end
#       end
#       workingUSNode._seen = true      # Mark node as visited
#     end
#   end
# end

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

	def select_upstream(manhole_id)
		# Method to select all upstream nodes, links, and catchments from a given manhole ID
		# Returns a hash with selected nodes, links, and catchments

		# Arrays to hold catchments, links, and nodes
		selected_nodes = []
		selected_links = []
		selected_catchments = []
		
		# Find the starting manhole node from @nodes
		mh = @nodes.find { |node| node.id == manhole_id }
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

	def select_upstream_nodes(manhole_id)
		# Method to select all upstream nodes from a given manhole ID
		# Returns void
		nodes = select_upstream(manhole_id)[:nodes]

		nodes.each do |node|
			node.selected = true
		end
	end

	def select_upstream_links(manhole_id)
		# Method to select all upstream links from a given manhole ID
		# Returns void
		links = select_upstream(manhole_id)[:links]

		links.each do |link|
			link.selected = true
		end
	end

	def select_upstream_catchments(manhole_id)
		# Method to select all upstream catchments from a given manhole ID
		# Returns void
		catchments = select_upstream(manhole_id)[:catchments]

		catchments.each do |catchment|
			catchment.selected = true
		end
	end

	def select_upstream_all(manhole_id)
		# Method to select all upstream nodes, links, and catchments from a given manhole ID
		# Returns void

		select_upstream_nodes(manhole_id)
		select_upstream_links(manhole_id)
		select_upstream_catchments(manhole_id)
	end

	def count_upstream_pipes(manhole_id)
		# Method to count all upstream pipes from a given manhole ID
		# Returns the count of upstream pipes

		upstream_links = select_upstream(manhole_id)[:links]
		return upstream_links.size
	end

	def calculate_total_length_upstream_pipes(manhole_id)
		# Method to calculate the total length of all upstream pipes from a given manhole ID
		# Returns the total length of upstream pipes

		upstream_links = select_upstream(manhole_id)[:links]
		total_length = 0.0

		upstream_links.each do |link|
			total_length += link.conduit_length
		end

		return total_length
	end

	def calculate_weighted_average_diameter(manhole_id)
		# Method to calculate the length weighted average diameter of all upstream pipes from a given manhole ID
		# Returns the length weighted average diameter

		upstream_links = select_upstream(manhole_id)[:links]
		total_diameter = 0.0
		total_length = 0.0

		upstream_links.each do |link|
			total_diameter += link.conduit_width * link.conduit_length
			total_length += link.conduit_length
		end

		return total_length > 0 ? (total_diameter / total_length) : 0.0
	end

end

mh = 'MH417664'

net = NetworkUtility.new(WSApplication.current_network)
puts net.count_upstream_pipes(mh)
puts net.calculate_total_length_upstream_pipes(mh)
puts net.calculate_weighted_average_diameter(mh)






