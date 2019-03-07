#!/usr/bin/env ruby

require_relative "test_runner"
require_relative "parameters"
require_relative "scenario"
require "securerandom"

raise "You must provide a template and parameters file" unless ARGV.length == 2

template_path = File.expand_path(ARGV[0])
default_parameters = Template::Parameters.from_file(File.expand_path(ARGV[1]))
uniq_base = SecureRandom.hex(10)

scenarios = [
  { "name" => "test-eastus", "parameters" => { "location" => { "value" => "eastus" } } },
  { "name" => "test-eastus2", "parameters" => { "location" => { "value" => "eastus2" } } },
  { "name" => "test-westus", "parameters" => { "location" => { "value" => "westus" } } },
  { "name" => "test-westus2", "parameters" => { "location" => { "value" => "westus2" } } },
  { "name" => "test-northcentralus", "parameters" => { "location" => { "value" => "northcentralus" } } },
  { "name" => "test-southcentralus", "parameters" => { "location" => { "value" => "southcentralus" } } },
  { "name" => "test-centralus", "parameters" => { "location" => { "value" => "centralus" } } },
  { "name" => "test-westcentralus", "parameters" => { "location" => { "value" => "westcentralus" } } },
  { "name" => "test-canadacentral", "parameters" => { "location" => { "value" => "canadacentral" } } },
  { "name" => "test-canadaeast", "parameters" => { "location" => { "value" => "canadaeast" } } },
  { "name" => "test-brazilsouth", "parameters" => { "location" => { "value" => "brazilsouth" } } },
  { "name" => "test-northeurope", "parameters" => { "location" => { "value" => "northeurope" } } },
  { "name" => "test-westeurope", "parameters" => { "location" => { "value" => "westeurope" } } },
  { "name" => "test-uksouth", "parameters" => { "location" => { "value" => "uksouth" } } },
  { "name" => "test-ukwest", "parameters" => { "location" => { "value" => "ukwest" } } },
  { "name" => "test-eastasia", "parameters" => { "location" => { "value" => "eastasia" } } },
  { "name" => "test-southeastasia", "parameters" => { "location" => { "value" => "southeastasia" } } },
  { "name" => "test-koreacentral", "parameters" => { "location" => { "value" => "koreacentral" } } },
  { "name" => "test-japanwest", "parameters" => { "location" => { "value" => "japanwest" } } },
  { "name" => "test-japaneast", "parameters" => { "location" => { "value" => "japaneast" } } },
  { "name" => "test-australiaeast", "parameters" => { "location" => { "value" => "australiaeast" } } },
  { "name" => "test-australiasoutheast", "parameters" => { "location" => { "value" => "australiasoutheast" } } },
  { "name" => "test-license",
    "parameters" => {
      "automateLicenseUri" => {
        "value" => "https://github.com/chef-partners/omnibus-marketplace/raw/master/files/chef-marketplace-cookbooks/chef-marketplace/files/default/delivery.license",
      },
    },
  },
  { "name" => "test-no-license",
    "parameters" => {
      "automateLicenseUri" => {
        "value" => "",
      },
    },
  },
  { "name" => "test-pub-key-auth",
    "parameters" => {
      "authenticationType" => {
        "value" => "sshPublicKey",
      },
      "sshPublicKey" => {
        "value" => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAl/1pYvhWDTIWyJJoFG2wKIkErOfb7aOESwBvqkjonV78qapecxsZSCx5OqrvZcEXV8bdkGLdUk3qhqF4Fb7usTNcI/QTfxo4L3vZ48RmI6ieiNhYxV15ORLocNGQGS7cZ96Q8vekUxrndcKLf2Ptw01EjW3mrdY18TMF6u68FeBsWv1L+nIxjtaLO1h/PClySpMzqrezfgCym0iqfa2dynk6FH/tErKNIkjNcGypQUeWkACD1rEVgL5eB4iDwSdlQFTfuA17RZ5/IYGe0OrTh9DaiDVjPG4IPMqVTrLdGm7DilCg6B0sB+GnN27Czaht5SsfpNRS1VtNKSQQBnMP",
        },
     },
  },
  { "name" => "test-vm-size",
    "parameters" => {
      "vmSize" => {
        "value" => "Standard_A2_v2",
        },
     },
  },
  { "name" => "test-premium-lrs-storage",
    "parameters" => {
      "storageAccountType" => {
        "value" => "Premium_LRS",
       },
      "vmSize" => {
        "value" => "Standard_DS4_v2",
      },
    },
  },
  { "name" => "test-standard-grs-diag-storage",
    "parameters" => {
      "diagnosticStorageAccountType" => {
        "value" => "Standard_GRS",
       },
    },
  },
  { "name" => "test-vnet-config",
    "parameters" => {
      "subnetName" => {
        "value" => "notdefault",
      },
      "subnetPrefix" => {
        "value" => "10.1.0.0/24",
      },
      "virtualNetworkAddressPrefix" => {
        "value" => "10.0.0.0/8",
       },
      "virtualNetworkName" => {
        "value" => "vnet02",
      },
    },
  },
].map do |scenario|
  # Merge override parameters into default params
  params = default_parameters.copy
  params.override(scenario.delete("parameters")) if scenario.key?("parameters")

  # Global resources require unique names
  scenario["name"] = "#{scenario["name"]}#{uniq_base}"[0..89]
  params["publicIPDnsName"]["value"] = "dns#{scenario["name"]}"[0..63]
  params["diagnosticStorageAccountName"]["value"] = "diag#{scenario["name"]}".gsub(/[\-\_\s]/, "")[0..23]
  params["storageAccountName"]["value"] = "disk#{scenario["name"]}".gsub(/[\-\_\s]/, "")[0..23]

  Template::Scenario.new(
    name: scenario["name"],
    setup_command: scenario.delete("setup_command") ||
      "azure group create" \
      " --json" \
      " -n '#{scenario["name"]}'" \
      " -l '#{params["location"]["value"]}'",
    command: scenario.delete("command") ||
      "azure group deployment create --json -q -f #{template_path} -p '#{params.to_json}' -g #{scenario["name"]}",
    log_command: scenario.delete("log_command") ||
      "azure group log show -n #{scenario["name"]} --all",
    delete_command: scenario.delete("delete_command") ||
      "azure group delete -q --nowait #{scenario["name"]}",
    retry_command: scenario.delete("retry_command") ||
      "azure group delete --json -q #{scenario["name"]}"
  )
end

# This special scenario will test all reusable resource code paths. In order for
# this to work we need to first create all resources that need to be reused
# in their own resource group, configure the parameters to use the existing
# resources and explicitly delete them after the test has run.
params = default_parameters.dup

name = "test-reuse#{uniq_base}"[0..89]

location = params["location"]["value"]

rgroup1 = "#{name}1"
rgroup2 = "#{name}2"

pub_ip =
  params["publicIPDnsName"]["value"] =
    params["publicIPAddressName"]["value"] =
      "dns#{name}"[0..63]
params["publicIPNewOrExisting"]["value"] = "existing"
params["publicIPAddressResourceGroup"]["value"] = rgroup1

diag_storage =
  params["diagnosticStorageAccountName"]["value"] =
    "diag#{name}".gsub(/[\-\_\s]/, "")[0..23]
diag_storage_sku = "LRS"
params["diagnosticStorageAccountType"]["value"] = "Standard_LRS"
params["diagnosticStorageAccountNewOrExisting"]["value"] = "existing"
params["diagnosticStorageAccountResourceGroup"]["value"] = rgroup1

disk_storage =
  params["storageAccountName"]["value"] =
    "disk#{name}".gsub(/[\-\_\s]/, "")[0..23]
storage_sku = "LRS"
params["storageAccountType"]["value"] = "Standard_LRS"
params["storageAccountNewOrExisting"]["value"] = "existing"
params["storageAccountResourceGroup"]["value"] = rgroup1

vnet =
  params["virtualNetworkName"]["value"] =
    "vnet#{name}".gsub(/[\-\_\s]/, "")[0..78]
vnet_prefix =
  params["virtualNetworkAddressPrefix"]["value"] =
    "10.0.0.0/16"
params["virtualNetworkNewOrExisting"]["value"] = "existing"
params["virtualNetworkResourceGroup"]["value"] = rgroup1

subnet = params["subnetName"]["value"]
subnet_prefix =
  params["subnetPrefix"]["value"] =
    "10.0.0.0/24"

scenarios << Template::Scenario.new(
  name: name,
  setup_command: [
    "azure group create --json -n '#{rgroup1}' -l '#{location}'",
    "azure group create --json -n '#{rgroup2}' -l '#{location}'",
    "azure network vnet create --json -n '#{vnet}' -l '#{location}' -g '#{rgroup1}' -a '#{vnet_prefix}'",
    "azure network vnet subnet create --json -g '#{rgroup1}' -e '#{vnet}' -n '#{subnet}' -a '#{subnet_prefix}'",
    "azure network public-ip create --json -l '#{location}' -g '#{rgroup1}' -n '#{pub_ip}' -d '#{pub_ip}'",
    "azure storage account create --json -l '#{location}' -g '#{rgroup1}' --sku-name '#{storage_sku}' --kind 'Storage' '#{disk_storage}'",
    "azure storage account create --json -l '#{location}' -g '#{rgroup1}' --sku-name '#{diag_storage_sku}' --kind 'Storage' '#{diag_storage}'",
  ].join(" && "),
  command: "azure group deployment create --json -q -f #{template_path} -p '#{params.to_json}' -g #{rgroup2}",
  log_command: "azure group log show -n #{rgroup2} --all",
  delete_command: "azure group delete -q --nowait #{rgroup2} && azure group delete -q --nowait #{rgroup1}",
  retry_command: "azure group delete -q #{rgroup2}"
)

Template::TestRunner.run(scenarios)
