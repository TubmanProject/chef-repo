# See https://docs.chef.io/config_rb.html for more information on configuration options

current_dir                  = File.dirname(__FILE__)

  user                       = ENV['OPSCODE_USER'] || ENV['USER']
  log_level                  :warn
  log_location               STDOUT
  node_name                  user
  client_key                 "#{current_dir}/#{user}.pem" # from Chef.io
  validation_client_name     'tubmanproject-validator' # "#{ENV['ORGNAME']}-validator"
  validation_key             "#{current_dir}/tubmanproject-validator.pem" # from Chef.io
  data_bag_encrypt_version   2
  encrypted_data_bag_secret  "#{current_dir}/encrypted_data_bag_secret"
  trusted_certs_dir          "#{current_dir}/trusted_certs"
  chef_server_url            "https://chef.mintyross.com/organizations/tubmanproject"
  chef_repo_path             "../#{current_dir}"
  cookbook_path              [
                              "#{current_dir}/../cookbooks"
                             ]
  data_bag_path              "#{current_dir}/../data_bags"
  environment_path           "#{current_dir}/../environment"
  role_path                  "#{current_dir}/../roles"
  cookbook_copyright         "Tyrone Saunders"
  cookbook_license           ""
  cookbook_email             ""

knife[:secret_file]           = "#{current_dir}/encrypted_data_bag_secret"
knife[:ssh_key_name]          = 'tubmanproject'
knife[:aws_access_key_id]     = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']
knife[:editor]                = "/usr/bin/vim"
