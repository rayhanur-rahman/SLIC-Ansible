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
  class Utils
    
    def initialize(node)
      @node = node.to_hash
    end

    def installDirectory
      return "#{@node['wlp']['base_dir']}/wlp"
    end

    def userDirectory
      return @node['wlp']['user_dir'] || "#{installDirectory}/usr"
    end
    
    def serversDirectory
      return "#{userDirectory}/servers"
    end

    def serverDirectory(server_name)
      return "#{serversDirectory}/#{server_name}"
    end

    def serverDirectoryExists?(server_name)
      return ::File.exists?(serverDirectory(server_name))
    end
    
    def user
      return @node['wlp']['user']
    end
    
    def group
      return @node['wlp']['group']
    end

    def createParentDirectory(dir)
      if ! File.exists?(dir)
        createParentDirectory(File.dirname(dir))
        FileUtils.mkdir(dir);
        chown(dir)
      end
    end

    def chown(file)
      FileUtils.chown(user, group, file)
    end
    
    def autoVersionUrls
      require 'open-uri'
      version_yml  = YAML::load(open(@node['wlp']['archive']['version_yaml']))

      use_beta = @node['wlp']['archive']['use_beta']

      runtime_uri = ''
      version_yml.each do |key, value|
        if !use_beta && key.start_with?('8.5')
          runtime_uri = ::URI.parse(value["uri"])
          # The newest version is the first one listed so break out after the first
          break
        end 
        if use_beta && key.start_with?('20')
          runtime_uri = ::URI.parse(value["uri"])
          break
        end
      end

      extended = "#{runtime_uri}"
      extended.sub! '-runtime-', '-extended-'
      extras = "#{runtime_uri}"
      extras.sub! '-runtime-', '-extras-'

      return ["#{runtime_uri}", extended, extras]
    end

  end
end
