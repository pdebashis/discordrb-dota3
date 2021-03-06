module Bot::DiscordCommands
  module Info
    extend Discordrb::Commands::CommandContainer
	  
	  command(:nist_stats) do |event|
		members_count = event.channel.server.member_count
        bots = event.channel.server.bot_members
		non_bots = event.channel.server.non_bot_members
		
		bots_count = bots.count
		non_bots_count = non_bots.count

		users_nicks = non_bots.map(&:display_name)
		batchwise = users_nicks.select do |usr| 
			/ 20[0-9][0-9]/ =~ usr
        end

		batchless = users_nicks.reject do |usr| 
			/ 20[0-9][0-9]/ =~ usr
        end

		result = {}

        batchwise.each do |usr|
          batch = usr[-4..-1]
          if result[batch]
            result[batch] << usr
          else
            result[batch] = [usr]
          end
        end

		print_matrix = ""

		result.keys.sort.each do |batch|
			print_matrix << "#{batch} :point_right: #{result[batch].count}\n"
        end

		event.channel.send_embed do |embed|
		  embed.colour = 0xff8040
		  embed.add_field name: "**NIST SERVER INFO**", value: "\n**Member Count**   : #{members_count}\n**Users**   : #{non_bots_count}\n **Bots** : #{bots_count}\n\n **Batchwise Members Count**\n\n #{print_matrix}\n **Batchless Members Count** : #{batchless.count}\n"
		end
	  end

	  command(:nist_others) do |event|
		users_nicks = event.channel.server.non_bot_members.map(&:display_name)
		batchless = users_nicks.reject do |usr| 
			/ 20[0-9][0-9]/ =~ usr
        end
		event.channel.send_message "#{batchless}"
	  end

	  command(:nist_users) do |event|
		users_nicks = event.channel.server.non_bot_members.map(&:display_name)
		event.channel.send_message "Generating CSV..."
		content=users_nicks.join("\n")
		begin
			o_fp = File.new( "/tmp/members.csv","w+")
			o_fp.write(content)
			o_fp.close
		    event.channel.send_file File.open('/tmp/members.csv', 'r')
		rescue
			raise "Unable to create output file"
		    event.channel.send_message "Oops, it didnt work..."
		end
	  end

	command(:nist_export) do |event,batchquery|
		members = event.channel.server.non_bot_members
		output = "nickname,username,batch\n"
		members.each do |member|
			nick=member.display_name
			usern=member.username	
			if nick =~ / 20[0-9][0-9]/
				batch = nick[-4..-1] 
			else
				batch = "unknown"
			end
			output+="#{nick},#{usern},#{batch}\n"
		end

		unless batchquery.nil?
		    unless batchquery =~/20[0-9][0-9]/
				event.channel.send_message "Something wrong in your command..."
				raise "Command not parsed"
			end 
		    members = output.split("\n")
			new_output = ""
			members.each do |member|
				new_output += "#{member}\n" if member.split(",").last == batchquery
			end
			output = new_output
		end
	    event.channel.send_message "Generating CSV..."
		begin
			o_fp = File.new( "/tmp/members.csv","w+")
			o_fp.write(output)
			o_fp.close
		    event.channel.send_file File.open('/tmp/members.csv', 'r')
		rescue
			raise "Unable to create output file"
		    event.channel.send_message "Oops, it didnt work..."
		end
  	end
  end
end