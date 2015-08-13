module Wonga
  module Pantry
    class ActiveDirectoryOU
      def initialize(record)
        @record = record
      end

      def ou
        if @record.domain == "test.#{CONFIG['pantry']['domain']}"
          "OU=INT,OU=#{escape(@record.team.name)},OU=Member Servers,DC=example,DC=com"
        else
          CONFIG['pantry']['default_ou']
        end
      end

      private

      def escape(name)
        name.parameterize[0..63]
      end
    end
  end
end
