if node['packages-additional']
  node['packages-additional'].each do |name, data|
    data = { action: data } if data.is_a?(String)
    package name do
      data.each do |key,value|
        self.send key, value
      end
    end
  end
end
