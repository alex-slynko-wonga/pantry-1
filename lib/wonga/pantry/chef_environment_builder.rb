class Wonga::Pantry::ChefEnvironmentBuilder
  def initialize(team, domain='test.example.com')
    @team = team
    @domain = domain
  end

  def build!
    e = Chef::Environment.new
    e.name("#{prepared_team_name}-env")
    e.default_attributes = attributes
    e.create
  end

  private
  def attributes
    {
      "authorization" => {
        "sudo" => {
          "groups" => [ "sysadmin" ],
          "users" => [ "deploy", "ubuntu" ],
          "passwordless" => true,
          "include_sudoers_d" => true
        }
      },
      "build_agent" => {
        "git_ssh_path" => "C:\\Jenkins",
        "jenkins_working_directory" => "C:\\Jenkins"
      },
      "build_essential" => {
        "compiletime" => true
      },
      "jenkins" => {
        "node" => {
          "auth_ad_domain" => "EXAMPLE",
          "auth_enabled" => true,
          "auth_user" => "ProvisionerUsername",
          "auth_password" => "ProvisionerPassword",
          "home" => "C:\\Jenkins"
        },
        "server" => {
          "host" => "#{prepared_team_name}.#{@domain}",
          "plugins" => [ "active-directory" ],
          "port" => 8080,
          "url" => "http://#{prepared_team_name}#{@domain}:8080"
        }
      }
    }
  end

  def prepared_team_name
    @prepared_name ||= @team.name.underscore.dasherize.gsub(/[^\-[:alnum:]_]/, "")
  end
end

