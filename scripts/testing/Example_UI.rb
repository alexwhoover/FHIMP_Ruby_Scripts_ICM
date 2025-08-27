net = WSApplication.current_network #This net object should be of class WSOpenNetwork

links = net.row_objects("hw_conduit")

net.transaction_begin # starts the transaction

links.each do |link|
    puts "Link Name: #{link.id}"
    if link.conduit_width < 300
        link.conduit_width = 300
    end
    link.write # writes change to the transaction
end

net.transaction_commit # This commits the changes to the software