import re
from urllib.parse import urlparse

text = 'www.google.com'


p = urlparse(text)
print(p)