module Wonga
  module Pantry
    class ActiveDirectoryOU
      def initialize(record)
        @record = record
      end

      def ou
        if @record.domain == "test.example.com"
          "OU=INT,OU=#{escape(@record.team.name)},OU=Member Servers,DC=test,DC=wonga,DC=com"
        else
          "OU=Computers,DC=wonga,DC=aws"
        end
      end

      private
      def escape(name)
        name = name.dup
        name.gsub!("\\", "\\\\\\")
        name.gsub!(",", "\\,")
        name = '\\' + name if name[0] == ' ' || name[0] == '#'
        name[-1] = '\ ' if name[-1] == ' '
        name
      end
    end
  end
end

