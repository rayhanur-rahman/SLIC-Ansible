s3_access_key ENV["AWS_ACCESS_KEY_ID"]
s3_secret_key ENV["AWS_SECRET_ACCESS_KEY"]
s3_bucket "opscode-omnibus-cache"
use_s3_caching true
build_retries 3
fetcher_read_timeout 120
workers 1
