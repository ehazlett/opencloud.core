require 'yaml'

Facter.add("roles") do
  setcode do
    begin
      cfg = File::open('/etc/opencloud/roles.yml')
      roles = YAML::load(cfg.read())
    end
    roles
  end
end
