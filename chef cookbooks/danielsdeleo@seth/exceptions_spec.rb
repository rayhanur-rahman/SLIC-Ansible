#
# Author:: Thomas Bishop (<bishop.thomas@gmail.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Kyle Goodwin (<kgoodwin@primerevenue.com>)
# Copyright:: Copyright (c) 2010 Thomas Bishop
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Seth::Exceptions do
  exception_to_super_class = {
    Seth::Exceptions::Application => RuntimeError,
    Seth::Exceptions::Cron => RuntimeError,
    Seth::Exceptions::Env => RuntimeError,
    Seth::Exceptions::Exec => RuntimeError,
    Seth::Exceptions::FileNotFound => RuntimeError,
    Seth::Exceptions::Package => RuntimeError,
    Seth::Exceptions::Service => RuntimeError,
    Seth::Exceptions::Route => RuntimeError,
    Seth::Exceptions::SearchIndex => RuntimeError,
    Seth::Exceptions::Override => RuntimeError,
    Seth::Exceptions::UnsupportedAction => RuntimeError,
    Seth::Exceptions::MissingLibrary => RuntimeError,
    Seth::Exceptions::MissingRole => RuntimeError,
    Seth::Exceptions::CannotDetermineNodeName => RuntimeError,
    Seth::Exceptions::User => RuntimeError,
    Seth::Exceptions::Group => RuntimeError,
    Seth::Exceptions::Link => RuntimeError,
    Seth::Exceptions::Mount => RuntimeError,
    Seth::Exceptions::PrivateKeyMissing => RuntimeError,
    Seth::Exceptions::CannotWritePrivateKey => RuntimeError,
    Seth::Exceptions::RoleNotFound => RuntimeError,
    Seth::Exceptions::ValidationFailed => ArgumentError,
    Seth::Exceptions::InvalidPrivateKey => ArgumentError,
    Seth::Exceptions::ConfigurationError => ArgumentError,
    Seth::Exceptions::RedirectLimitExceeded => RuntimeError,
    Seth::Exceptions::AmbiguousRunlistSpecification => ArgumentError,
    Seth::Exceptions::CookbookNotFound => RuntimeError,
    Seth::Exceptions::AttributeNotFound => RuntimeError,
    Seth::Exceptions::InvalidCommandOption => RuntimeError,
    Seth::Exceptions::CommandTimeout => RuntimeError,
    Mixlib::ShellOut::ShellCommandFailed => RuntimeError,
    Seth::Exceptions::RequestedUIDUnavailable => RuntimeError,
    Seth::Exceptions::InvalidHomeDirectory => ArgumentError,
    Seth::Exceptions::DsclCommandFailed => RuntimeError,
    Seth::Exceptions::UserIDNotFound => ArgumentError,
    Seth::Exceptions::GroupIDNotFound => ArgumentError,
    Seth::Exceptions::InvalidResourceReference => RuntimeError,
    Seth::Exceptions::ResourceNotFound => RuntimeError,
    Seth::Exceptions::InvalidResourceSpecification => ArgumentError,
    Seth::Exceptions::SolrConnectionError => RuntimeError,
    Seth::Exceptions::InvalidDataBagPath => ArgumentError,
    Seth::Exceptions::InvalidEnvironmentPath => ArgumentError,
    Seth::Exceptions::EnvironmentNotFound => RuntimeError,
    Seth::Exceptions::InvalidVersionConstraint => ArgumentError,
    Seth::Exceptions::IllegalVersionConstraint => NotImplementedError
  }

  exception_to_super_class.each do |exception, expected_super_class|
    it "should have an exception class of #{exception} which inherits from #{expected_super_class}" do
      lambda{ raise exception }.should raise_error(expected_super_class)
    end
  end
end
