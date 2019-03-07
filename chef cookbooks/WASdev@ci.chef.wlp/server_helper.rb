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
  class ServerHelper
    
    def initialize(node)
      @utils = Utils.new(node)
    end
    
    def exists?(server_name)
      return @utils.serverDirectoryExists?(server_name)
    end
    
    def running?(server_name)
      if exists?(server_name)
        status = runCommand("status #{server_name}")
        return status.exitstatus == 0
      else
        return false
      end
    end

    def dump(server_name, archive, types = [])
      if exists?(server_name)
        command = "dump #{server_name} --archive=#{archive}"
        if types && !types.empty?
          command << " --include=#{types.join(",")}"
        end
        dump = runCommand(command)
        dump.error!
        return true
      else
        return false
      end
    end

    def package(server_name, archive, type = nil)
      if exists?(server_name)
        command = "package #{server_name} --archive=#{archive}"
        if type
          command << " --include=#{type}"
        end
        package = runCommand(command)
        package.error!
        return true
      else
        return false
      end
    end

    private

    def runCommand(arguments) 
      command = Mixlib::ShellOut.new("#{@utils.installDirectory}/bin/server #{arguments}", :user => @utils.user, :group => @utils.group)
      command.run_command
    end
    
  end
end
