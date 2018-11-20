def update_line_tods(line)
        pattern = /#<Tod::TimeOfDay:0x\h+ @hour=(\d+), @minute=(\d+), @second=(\d+), @second_of_day=\d+>/
        while( match = line.match(pattern) )
                line.gsub!(pattern, "\"#{match[1].rjust(2,'0')}:#{match[2].rjust(2,'0')}:#{match[3].rjust(2,'0')}\"")
        end
        return line
end


while(s=gets)
        s = update_line_tods(s)

        current_model = nil
        if match = s.match(/\A(.+)\.create/)
                current_model = match[1]
        end

        if current_model = 'User' && s.start_with?("  {email")
                puts "u = User.new(#{s.strip.gsub('},', '}')})"
                puts "u.save(:validate => false)"
        else
                puts s
        end
end

