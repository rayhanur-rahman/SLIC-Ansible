# <
# Sets the environment language with that subscription-manager commands are executed. The output of that command is localized and non English
# output breaks the output parsing of this cookbook. Therefore changing the default may break this cookbook.
# >
default['rhsm']['lang'] = 'en_US'
