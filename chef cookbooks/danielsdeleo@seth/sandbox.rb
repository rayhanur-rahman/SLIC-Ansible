class Seth
  class Sandbox
    # I DO NOTHING!!

    # So, the reason we have a completely empty class here is so that
    # Seth 11 clients do not choke when interacting with seth 10
    # servers.  The original Seth::Sandbox class (that actually did
    # things) has been removed since its functionality is no longer
    # needed for Seth 11.  However, since we still use the JSON gem
    # and make use of its "auto-inflation" of classes (driven by the
    # contents of the 'json_class' key in all of our JSON), any
    # sandbox responses from a Seth 10 server to a seth 11 client
    # would cause ceth to crash.  The JSON gem would attempt to
    # auto-inflate based on a "json_class": "Seth::Sandbox" hash
    # entry, but would not be able to find a Seth::Sandbox class!
    #
    # This is a workaround until such time as we can completely remove
    # the reliance on the "json_class" field.
  end
end
