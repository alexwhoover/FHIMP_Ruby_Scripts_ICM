# SimUtility
#
# This class provides utility methods for accessing and processing simulation results from a proprietary 
# simulation object. It acts as a wrapper to simplify extracting data from simulation tables and 
# exporting results to CSV format.
#
# Key Features:
# - Extracts time series data from simulation result tables and calculates maximum values
# - Creates dictionary mappings between specified key and value fields
# - Exports dictionaries to CSV files with custom headers
# - Handles nil results gracefully (common for outfall nodes)
#
# Dependencies:
# - csv: Ruby standard library for CSV file operations
#
# Class Attributes:
# - @sim: The simulation object passed during initialization
# - @network: The opened network from the simulation object
#
# Methods:
# - return_field_dictionary(table_name, key_field, value_field): Extracts data from results table as hash
# - export_dictionary_to_csv(path, field_dictionary, key_header, field_header): Exports hash to CSV
#
# Usage:
#   util = SimUtility.new(sim)
#   flooding_dict = util.return_field_dictionary('_nodes', 'id', 'flooding_volume')
#   util.export_dictionary_to_csv('flooding.csv', flooding_dict, 'Node_ID', 'Max_Flooding')
#
#   # Multiple field extraction
#   depths = util.return_field_dictionary('_nodes', 'id', 'depth')
#   flows = util.return_field_dictionary('_links', 'id', 'flow')
#   util.export_dictionary_to_csv('depths.csv', depths, 'Node', 'Max_Depth')
#   util.export_dictionary_to_csv('flows.csv', flows, 'Link', 'Max_Flow')
#
# Note:
# - The class assumes result fields return time series arrays where .max provides meaningful analysis
# - Nil results are automatically skipped (common for certain node types like outfalls)
# - The simulation object must support .open method and resulting network must support .row_object_collection

require 'csv'

class SimUtility
    attr_accessor :sim

    def initialize(sim)
        @sim = sim
        @network = @sim.open
    end

    def return_field_dictionary(table_name, key_field, value_field)
        # Returns a hash where key_field is the key and value_field is the value from the specified results table
        result_hash = {}
        @network.row_object_collection(table_name).each do |row_object|
            key = row_object[key_field]
            results = row_object.results(value_field)

            # If nil result, common for outfall nodes, go to next row_object
            next if results.nil?

            # Calculate max value, as .results(value_field) returns an array of results for each timestep
            value = results.max
            result_hash[key] = value
        end
        result_hash
    end

    def export_dictionary_to_csv(path, table_name, key_field, value_field)
        field_dictionary = return_field_dictionary(table_name, key_field, value_field)

        CSV.open(path, 'w') do |csv|
            csv << [key_field, value_field]
            field_dictionary.each do |key, value|
                csv << [key, value]
            end
        end
    end
end