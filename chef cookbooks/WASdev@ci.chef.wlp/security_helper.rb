# Cookbook Name:: wlp
# Attributes:: default
#
# (C) Copyright IBM Corporation 2013.
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

module Liberty
  class SecurityHelper
    
    def initialize(node)
      @utils = Utils.new(node)
    end
    
    def encode(text, encoding_type = "xor", encryption_key = nil)
      command = "encode --encoding=#{encoding_type}"
      if encryption_key
        command << " --key=#{encryption_key}"
      end
      command << " \"#{text}\""
      status = runCommand(command)
      status.error!
      return status.stdout.strip
    end

    private

    def runCommand(arguments) 
      command = Mixlib::ShellOut.new("#{@utils.installDirectory}/bin/securityUtility #{arguments}", :user => @utils.user, :group => @utils.group)
      command.run_command
    end
    
  end
end
