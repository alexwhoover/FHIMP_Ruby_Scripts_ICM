# Utility class for accessing simulation results.
#
# Provides methods to retrieve results from simulation tables.
#
# @attr sim [Object] The simulation object.
#
# Example:
#   util = SimUtility.new(sim)
#   util.results('field_name', 'table_name')
class SimUtility
    attr_accessor: :sim

    def initialize(sim)
        @sim = sim
        @network = @sim.open
    end

    def results(field_name, table_name)
        # Returns an array of results for a given field_name in a results table (for example hw_node)
        results_array = []
        @network.row_object_collection(table_name).each do |row_object|
            value = row_object.results(field_name)
            results_array << value
        end
        @network.row_object_collection('hw_node').each do |row_object|
            value = row_object.results(field_name)
            results_array << value
        end
        results_array
    end
end