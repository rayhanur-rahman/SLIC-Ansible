bash 'http server' do
  cwd '/var/log'
  code <<-EOS
    while true
    do
      echo 'HTTP/1.1 200 OK\r\n' | nc -l 5001
    done > dmon.log &
  EOS
end
