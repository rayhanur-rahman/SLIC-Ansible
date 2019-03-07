
shared_context "diff disabled"  do
  before do
    Seth::Config[:diff_disabled] = true
  end

  after do
    Seth::Config[:diff_disabled] = false
  end
end
